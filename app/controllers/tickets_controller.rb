class TicketsController < ApplicationController
  before_filter :login_required
#  before_action :set_ticket, only: [:show, :edit, :update, :destroy]

  # GET /tickets
  # GET /tickets.json
  def index
    authorize! :index, :tickets
    @status = "#{params[:status].blank? ? '2' : params[:status]}"
    @currencies = Ticket.currencies(current_user.token)
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @sort_column = params[:sort_column] ||= 'DateCreated'
    @sort_direction = params[:sort_direction] ||= @status == '3' ? 'Descending' : 'Ascending'
    @drawers = Drawer.all(current_user.token, current_yard_id, current_user.currency_id)
#    @checking_accounts = CheckingAccount.all(current_user.token, current_yard_id)
    
    unless params[:q].blank?
      results = Ticket.search(@status.to_i, current_user.token, current_yard_id, params[:q])
    else
      unless current_user.customer?
        if @start_date.blank? and @end_date.blank?
          results = Ticket.all_by_status_and_yard(@status.to_i, current_user.token, current_yard_id)
        else
          results = Ticket.all_by_date_and_status_and_yard(@status.to_i, current_user.token, current_yard_id, @start_date, @end_date)
        end
      else
        if @start_date.blank? and @end_date.blank?
          results = Customer.tickets(@status.to_i, current_user.token, current_yard_id, current_user.customer_guid)
        else
          results = Ticket.all_by_date_and_customers(@status.to_i, current_user.token, current_yard_id, @start_date, @end_date, current_user.portal_customer_ids) 
#          current_user.portal_customers.each do |portal_customer|
#            portal_customer_results = Customer.tickets(@status.to_i, current_user.token, current_yard_id, portal_customer.customer_guid)
#            results = [] if results.blank? # Create an empty array to add to if there are no results yet
#            results = results + portal_customer_results unless portal_customer_results.blank?
#          end
        end
      end
    end
    unless results.blank?
      if @sort_direction == 'Descending'
        results = results.sort_by{|ticket| ticket["#{@sort_column}"]}.reverse
      else
        results = results.sort_by{|ticket| ticket["#{@sort_column}"]}
      end
#      results = results.sort_by{|ticket| ticket["DateCreated"]} if @status == '2'
#      results = results.sort_by{|ticket| ticket["DateCreated"]}.reverse if @status == '1' or @status == '3'
      @tickets = Kaminari.paginate_array(results).page(params[:page]).per(10)
    else
      @tickets = []
    end
  end
  
  # GET /customer_tickets
  # GET /customer_tickets.json
  def customer_tickets
    authorize! :customer_index, :tickets
    status = 3
    unless params[:q].blank?
      results = Ticket.customer_search(status, current_user.token, current_yard_id, current_user.customer_guid, params[:q])
    else
      results = Ticket.customer_all(status, current_user.token, current_yard_id, current_user.customer_guid)
    end
    unless results.blank?
      @tickets = Kaminari.paginate_array(results).page(params[:page]).per(10)
    else
      @tickets = []
    end
  end

  # GET /tickets/1
  # GET /tickets/1.json
  def show
    authorize! :show, :tickets
    @ticket = Ticket.find_by_id(current_user.token, params[:yard_id].blank? ? current_yard_id : params[:yard_id], params[:id])
    @ticket_number = @ticket["TicketNumber"]
    @accounts_payable_items = AccountsPayable.all(current_user.token, @ticket["YardId"], params[:id])
    @apcashier = Apcashier.find_by_id(current_user.token, @ticket["YardId"], @accounts_payable_items.first['CashierId']) if @ticket['Status'] == '3'
    unless @ticket["TicketItemCollection"].blank?
      unless @ticket["TicketItemCollection"]["ApiTicketItem"].is_a? Hash
        @line_items = @ticket["TicketItemCollection"]["ApiTicketItem"].select {|i| i["Status"] == '0'} 
      else
        if @ticket["TicketItemCollection"]["ApiTicketItem"]["Status"] == '0'
          @line_items = [@ticket["TicketItemCollection"]["ApiTicketItem"]]
        end
      end
    end
    
    @images_array = Image.api_find_all_by_ticket_number(@ticket_number, current_user.company, @ticket["YardId"]).reverse # Ticket images
    rt_lookups = RtLookup.api_find_all_by_ticket_number(@ticket_number, current_user.company, @ticket["YardId"])
    rt_lookups.each do |rt_lookup|
      rt_lookup_images = Image.api_find_all_by_receipt_number(rt_lookup['RECEIPT_NBR'], current_user.company, @ticket["YardId"]).reverse
      @images_array =  @images_array | rt_lookup_images # Union the image arrays
    end
  
    respond_to do |format|
      format.html{}
      format.pdf do
#        @signature_image = Image.where(ticket_nbr: @ticket_number, yardid: current_yard_id, event_code: "SIGNATURE CAPTURE").last
        @signature_image = Image.api_find_first_by_ticket_number_and_event_code(@ticket_number, current_user.company, @ticket["YardId"], "Signature")
        unless @signature_image.blank?
          @signature_blob = Image.jpeg_image(current_user.company, @signature_image['CAPTURE_SEQ_NBR'], @ticket["YardId"])
        end
#        @finger_print_image = Image.where(ticket_nbr: @doc_number, yardid: current_yard_id, event_code: "Finger Print").last
        @finger_print_image = Image.api_find_first_by_ticket_number_and_event_code(@ticket_number, current_user.company, @ticket["YardId"], "Finger Print")
        unless @finger_print_image.blank?
          @finger_print_blob = Image.jpeg_image(current_user.company, @finger_print_image['CAPTURE_SEQ_NBR'], @ticket["YardId"])
        end
        
        unless current_user.printer_devices.blank?
          printer = current_user.printer_devices.last
          render pdf: "ticket#{@ticket_number}",
            :layout => 'pdf.html.haml',
            :zoom => "#{printer.PrinterWidth < 10 ? 2 : 1.25}",
            :save_to_file => Rails.root.join('pdfs', "#{@ticket['YardId']}Ticket#{@ticket_number}.pdf")
          printer.call_printer_for_ticket_pdf(Base64.encode64(File.binread(Rails.root.join('pdfs', "#{@ticket['YardId']}Ticket#{@ticket_number}.pdf"))))
          # Remove the temporary pdf file that was created above
          FileUtils.remove(Rails.root.join('pdfs', "#{@ticket['YardId']}Ticket#{@ticket_number}.pdf"))
        else
          render pdf: "ticket#{@ticket_number}",
            :layout => 'pdf.html.haml',
            :zoom => 1.25
        end
      end
    end
  end

  # GET /tickets/new
  def new
#    @ticket = Ticket.new
    if @ticket_number.blank?
      @ticket_number = Ticket.next_available_number(current_user.token, current_yard_id)
    end
    @guid = SecureRandom.uuid
  end

  # GET /tickets/1/edit
  def edit
    authorize! :edit, :tickets
    @drawers = Drawer.all(current_user.token, current_yard_id, current_user.currency_id)
    @checking_accounts = CheckingAccount.all(current_user.token, current_yard_id)
    @ticket = Ticket.find_by_id(current_user.token, current_yard_id, params[:id])
    @accounts_payable_items = AccountsPayable.all(current_user.token, current_yard_id, params[:id])
    @ticket_number = @ticket["TicketNumber"]
    @images_array = Image.api_find_all_by_ticket_number(@ticket_number, current_user.company, current_yard_id).reverse # Ticket images
    unless @ticket["TicketItemCollection"].blank?
      unless @ticket["TicketItemCollection"]["ApiTicketItem"].is_a? Hash
        @line_items = @ticket["TicketItemCollection"]["ApiTicketItem"].select {|i| i["Status"] == '0'} unless @ticket["TicketItemCollection"].blank?
      else
        if @ticket["TicketItemCollection"]["ApiTicketItem"]["Status"] == '0'
          @line_items = [@ticket["TicketItemCollection"]["ApiTicketItem"]]
        end
      end
    end
#    @commodity_types = Commodity.types(current_user.token, current_yard_id)
#    @commodities = Commodity.all(current_user.token, current_yard_id)
#    @commodities_grouped_by_type_for_select = Commodity.all_by_type_grouped_for_select(@commodity_types, @commodities)
#    @images = Image.where(ticket_nbr: @ticket["TicketNumber"], yardid: current_yard_id)
#    @contract = Yard.contract(current_yard_id)
    @apcashier = Apcashier.find_by_id(current_user.token, current_yard_id, @accounts_payable_items.first['CashierId']) if @ticket['Status'] == '3'
#    AccountsPayable.update(current_user.token, current_yard_id, params[:id], @accounts_payable_items.last)
    rt_lookups = RtLookup.api_find_all_by_ticket_number(@ticket_number, current_user.company, current_yard_id)
    rt_lookups.each do |rt_lookup|
      rt_lookup_images = Image.api_find_all_by_receipt_number(rt_lookup['RECEIPT_NBR'], current_user.company, current_yard_id).reverse
      @images_array =  @images_array | rt_lookup_images # Union the image arrays
    end
    
    @combolists = Vehicle.combolists(current_user.token)
    @vehicle_makes = (@combolists.blank? or @combolists["VehicleMakes"].blank?) ? [] : @combolists["VehicleMakes"]["VehicleMakeInformation"]
    @vehicle_models = (@combolists.blank? or @combolists["VehicleModels"].blank?) ? [] : @combolists["VehicleModels"]["VehicleModelInformation"]
    @body_styles = (@combolists.blank? or @combolists["VehicleBodyStyles"].blank?) ? [] : @combolists["VehicleBodyStyles"]["UserDefinedListValueQuickInformation"]
    @vehicle_colors = (@combolists.blank? or @combolists["VehicleColors"].blank?) ? [] : @combolists["VehicleColors"]["UserDefinedListValueQuickInformation"]
    
    @deductions = Ticket.deductions(current_user.token)
    @deductions_grouped_for_select = Ticket.deductions_grouped_for_select(@deductions)
  end

  # PATCH/PUT /tickets/1
  # PATCH/PUT /tickets/1.json
  def update
    respond_to do |format|
#      @drawers = Drawer.all(current_user.token, current_yard_id)
      unless ticket_params[:line_items].blank?
        ticket_params[:line_items].each do |line_item|
          if line_item[:status].blank?
            unless line_item[:commodity].blank?
              # Create new item
              Ticket.add_item(current_user.token, current_yard_id, params[:id], line_item[:id], line_item[:commodity], line_item[:gross], 
                line_item[:tare], line_item[:net], line_item[:price], line_item[:amount], line_item[:notes], line_item[:serial_number],
                ticket_params[:customer_id], line_item[:unit_of_measure], line_item[:deductions])
            end
          else
            unless line_item[:commodity].blank?
              # Update existing item
              Ticket.update_item(current_user.token, current_yard_id, params[:id], line_item[:id], line_item[:commodity], line_item[:gross], 
                line_item[:tare], line_item[:net], line_item[:price], line_item[:amount], line_item[:notes], line_item[:serial_number],
                ticket_params[:customer_id], line_item[:unit_of_measure], line_item[:deductions])
              
            end
          end
        end
      end
      @ticket = "true"
      ### Save Ticket ###
      if params[:save]
        @ticket = Ticket.update(current_user.token, current_yard_id, ticket_params[:customer_id], params[:id], ticket_params[:ticket_number], ticket_params[:status], ticket_params[:description])
      ### End Save Ticket ###
      ### Close Ticket ###
      elsif params[:close_ticket]
        @ticket = Ticket.update(current_user.token, current_yard_id, ticket_params[:customer_id], params[:id], ticket_params[:ticket_number], 1, ticket_params[:description])
      ### End Close Ticket ###
      ### Close Ticket ###
      elsif params[:void_ticket]
        @ticket = Ticket.update(current_user.token, current_yard_id, ticket_params[:customer_id], params[:id], ticket_params[:ticket_number], 5, ticket_params[:description])
      ### End Close Ticket ###
      ### Pay Ticket ###
      elsif params[:pay_ticket]
        Ticket.update(current_user.token, current_yard_id, ticket_params[:customer_id], params[:id], ticket_params[:ticket_number], ticket_params[:status], ticket_params[:description])
        @accounts_payable_items = Ticket.accounts_payable_items(current_user.token, current_yard_id, params[:id])
        if params[:payment_type] == 'check'
          @ticket = Ticket.pay_by_check(current_user.token, current_yard_id, params[:id], @accounts_payable_items.last['Id'], params[:drawer_id], 
            params[:checking_account_payment][:id], params[:checking_account_payment][:name], params[:checking_account_payment][:check_number], params[:payment_amount])
        else
          @ticket = Ticket.pay_by_cash(current_user.token, current_yard_id, params[:id], @accounts_payable_items.last['Id'], params[:drawer_id], params[:payment_amount])
        end
      ### End Pay Ticket ###
      ### Close & Pay Ticket ###
      elsif params[:close_and_pay_ticket]
        Ticket.update(current_user.token, current_yard_id, ticket_params[:customer_id], params[:id], ticket_params[:ticket_number], 1, ticket_params[:description])
        @accounts_payable_items = Ticket.accounts_payable_items(current_user.token, current_yard_id, params[:id])
        if params[:payment_type] == 'check'
          @ticket = Ticket.pay_by_check(current_user.token, current_yard_id, params[:id], @accounts_payable_items.last['Id'], params[:drawer_id], 
          params[:checking_account_payment][:id], params[:checking_account_payment][:name], params[:checking_account_payment][:check_number], params[:payment_amount])
        else
          @ticket = Ticket.pay_by_cash(current_user.token, current_yard_id, params[:id], @accounts_payable_items.last['Id'], params[:drawer_id], params[:payment_amount])
        end
      ### End Close & Pay Ticket ###
      else
        @ticket = Ticket.update(current_user.token, current_yard_id, ticket_params[:customer_id], params[:id], ticket_params[:ticket_number], ticket_params[:status], ticket_params[:description])
      ### No button params, so Void Ticket ###
#        @ticket = Ticket.update(current_user.token, current_yard_id, ticket_params[:customer_id], params[:id], ticket_params[:ticket_number], 0)
      ### End Void Ticket ###
      end
      format.html { 
        if @ticket == 'true'
          flash[:success] = 'Ticket was successfully updated.'
        else
          flash[:danger] = 'Error updating ticket.'
        end
        redirect_to tickets_path(status: ticket_params[:status]) unless params[:pay_ticket] or params[:close_and_pay_ticket]
        # Redirect to paid tickets list so can print
        redirect_to tickets_path(status: '3') if params[:pay_ticket] or params[:close_and_pay_ticket]
        }
    end
  end
  
  def line_item_fields
    @ticke_number = params[:ticket_number]
    @ticket_id = params[:ticket_id]
    
#    @combolists = Vehicle.combolists(current_user.token)
#    @combolists = params[:combolists]
#    @vehicle_makes = (@combolists.blank? or @combolists["VehicleMakes"].blank?) ? [] : @combolists["VehicleMakes"]["VehicleMakeInformation"]
#    @vehicle_models = (@combolists.blank? or @combolists["VehicleModels"].blank?) ? [] : @combolists["VehicleModels"]["VehicleModelInformation"]
#    @body_styles = (@combolists.blank? or @combolists["VehicleBodyStyles"].blank?) ? [] : @combolists["VehicleBodyStyles"]["UserDefinedListValueQuickInformation"]
#    @vehicle_colors = (@combolists.blank? or @combolists["VehicleColors"].blank?) ? [] : @combolists["VehicleColors"]["UserDefinedListValueQuickInformation"]
    @deductions = Ticket.deductions(current_user.token)
    @deductions_grouped_for_select = Ticket.deductions_grouped_for_select(@deductions)
    @vehicle_makes = []
    @vehicle_models = []
    @body_styles = []
    @vehicle_colors = []
    respond_to do |format|
      format.js
    end
  end
  
  def void_item
    respond_to do |format|
      format.html {}
      format.json {
        @ticket = TicketItem.void(current_user.token, current_yard_id, params[:ticket_id], params[:item_id], params[:commodity_id], params[:gross], 
          params[:tare], params[:net], params[:price], params[:amount])
        if @ticket == 'true'
          render json: {}, :status => :ok
        else
          render json: {}, status: :unprocessable_entity
        end
      }
    end
  end
  
  def vin_search
    respond_to do |format|
      format.html {}
      format.json {
        @search_results = Ticket.vin_search(current_user.token, params[:vin])
        Rails.logger.debug @search_results
        if @search_results
          render json: {"valid" => @search_results['IsValid'], "year" => @search_results['Year1'], 
            "make" => @search_results['DecodedText']['Make'], "make_id" => @search_results['VehicleMakeId'], "added_make" => @search_results["AddedMake"],
            "model" => @search_results['DecodedText']['Model'], "model_id" => @search_results['VehicleModelId'], "added_model" => @search_results["AddedModel"],
            "body" => @search_results['DecodedText']['Style'], "body_id" => @search_results['BodyStyleId'], "added_body" => @search_results["AddedStyle"]}, status: :ok
        else
          render json: {error: "VIN search failed."}, :status => :bad_request
        end
      }
    end
  end

  # DELETE /tickets/1
  # DELETE /tickets/1.json
#  def destroy
#    @ticket.destroy
#    respond_to do |format|
#      format.html { redirect_to tickets_url, notice: 'Ticket was successfully destroyed.' }
#      format.json { head :no_content }
#    end
#  end
  
  # DELETE /tickets/1
  # DELETE /tickets/1.json
  def destroy
    authorize! :void, :tickets
    respond_to do |format|
      format.html {
#        if Ticket.void(current_user.token, current_yard_id, params[:ticket]) == 'true'
        if Ticket.void(current_user.token, current_yard_id, params[:id]) == 'true'
          flash[:success] = 'Ticket was successfully voided.'
        else
          flash[:danger] = 'Error voiding ticket.'
        end
        redirect_to tickets_path(status: params[:status])
      }
    end
  end
  
  def send_to_leads_online
    authorize! :send_to_leads_online, :tickets
#    
    path_to_file = "public/leads_online/f_0_#{current_user.company.leads_online_store_id}_#{Date.today.strftime("%m")}_#{Date.today.strftime("%d")}_#{Date.today.strftime("%Y")}_#{Time.now.strftime("%H%M%S")}.xml"
    SendTicketToLeadsWorker.perform_async(current_user.token, path_to_file, params[:id], current_yard_id, current_user.id)

    respond_to do |format|
      format.html { 
        flash[:success] = 'Ticket details sent to Leads Online.' 
        redirect_to :back 
        }
    end
  end
  
  # GET /tickets/1/email
  def email
    authorize! :show, :tickets
    @ticket = Ticket.find_by_id(current_user.token, params[:yard_id].blank? ? current_yard_id : params[:yard_id], params[:id])
    unless @ticket["TicketItemCollection"].blank?
      unless @ticket["TicketItemCollection"]["ApiTicketItem"].is_a? Hash
        @line_items = @ticket["TicketItemCollection"]["ApiTicketItem"].select {|i| i["Status"] == '0'} 
      else
        if @ticket["TicketItemCollection"]["ApiTicketItem"]["Status"] == '0'
          @line_items = [@ticket["TicketItemCollection"]["ApiTicketItem"]]
        end
      end
    end
    @images_array = Image.api_find_all_by_ticket_number(@ticket_number, current_user.company, @ticket["YardId"]).reverse # Ticket images
    rt_lookups = RtLookup.api_find_all_by_ticket_number(@ticket_number, current_user.company, @ticket["YardId"])
    rt_lookups.each do |rt_lookup|
      rt_lookup_images = Image.api_find_all_by_receipt_number(rt_lookup['RECEIPT_NBR'], current_user.company, @ticket["YardId"]).reverse
      @images_array =  @images_array | rt_lookup_images # Union the image arrays
    end
    @recipients = params[:recipients]
    UserMailer.ticket_information(@ticket, @line_items, @recipients).deliver
    respond_to do |format|
      format.html { 
        flash[:success] = 'Ticket details emailed to recipients.' 
        redirect_to :back 
        }
    end
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ticket_params
      params.require(:ticket).permit(:ticket_number, :customer_id, :id, :status, :description, line_items: [:id, :commodity, :gross, :tare, :net, :price, 
          :amount, :tax_amount, :status, :notes, :serial_number, :unit_of_measure, :tax_amount_1, :tax_amount_2, :tax_amount_3, :tax_percent_1, :tax_percent_2, :tax_percent_3,
          deductions: [:deduct_weight_description, :deduct_weight, :deduct_dollar_amount_description, :deduct_dollar_amount, :id] ])
    end
end
