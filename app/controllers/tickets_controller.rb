class TicketsController < ApplicationController
  before_filter :login_required
#  before_action :set_ticket, only: [:show, :edit, :update, :destroy]

  # GET /tickets
  # GET /tickets.json
  def index
    authorize! :index, :tickets
    @status = "#{params[:status].blank? ? '2' : params[:status]}"
    @drawers = Drawer.all(current_user.token, current_yard_id)
    @checking_accounts = CheckingAccount.all(current_user.token, current_yard_id)
    
    unless params[:q].blank?
      results = Ticket.search(@status, current_user.token, current_yard_id, params[:q])
    else
      results = Ticket.all(@status, current_user.token, current_yard_id) unless current_user.customer?
#      results = Ticket.search(3, current_user.token, current_yard_id, current_user.company_name) if current_user.customer?
#      results = Customer.paid_tickets(current_user.token, current_yard_id, current_user.customer_guid) if current_user.customer?
      results = Customer.tickets(@status, current_user.token, current_yard_id, current_user.customer_guid) if current_user.customer?
    end
    unless results.blank?
      results = results.reverse if @status == 'held'
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
#    @ticket = Ticket.find_by_id_and_ticket_number(params[:status], current_user.token, current_yard_id, params[:id], params[:ticket_number])
    @ticket = Ticket.find_by_id(params[:status], current_user.token, current_yard_id, params[:id])
    @ticket_number = @ticket["TicketNumber"]
    @accounts_payable_items = AccountsPayable.all(current_user.token, current_yard_id, params[:id])
#    @images = Image.where(ticket_nbr: @ticket["TicketNumber"], yardid: current_yard_id, cust_nbr: current_user.customer_guid)
    respond_to do |format|
      format.html{}
      format.pdf do
        @signature_image = Image.where(ticket_nbr: @ticket_number, yardid: current_yard_id, event_code: "SIGNATURE CAPTURE").last
        @finger_print_image = Image.where(ticket_nbr: @doc_number, yardid: current_yard_id, event_code: "Finger Print").last
        render pdf: "ticket#{@ticket_number}",
          :layout => 'pdf.html.haml',
          :zoom => 1.25
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
    @drawers = Drawer.all(current_user.token, current_yard_id)
    @checking_accounts = CheckingAccount.all(current_user.token, current_yard_id)
#    @ticket = Ticket.find_by_id(params[:status], current_user.token, current_yard_id, params[:id])
    @ticket = Ticket.find_by_id(params[:status], current_user.token, current_yard_id, params[:id])
    @accounts_payable_items = AccountsPayable.all(current_user.token, current_yard_id, params[:id])
    @ticket_number = @ticket["TicketNumber"]
    @line_items = @ticket["TicketItemCollection"]["ApiTicketItem"].select {|i| i["Status"] == '0'} unless @ticket["TicketItemCollection"].blank?
    @commodities = Commodity.all(current_user.token, current_yard_id)
#    @images = Image.where(ticket_nbr: @ticket["TicketNumber"], yardid: current_yard_id)
    @contract = Yard.contract(current_yard_id)
  end

  # PATCH/PUT /tickets/1
  # PATCH/PUT /tickets/1.json
  def update
    respond_to do |format|
#      @drawers = Drawer.all(current_user.token, current_yard_id)
      ticket_params[:line_items].each do |line_item|
        if line_item[:status].blank?
          # Create new item
          Ticket.add_item(current_user.token, current_yard_id, params[:id], line_item[:commodity], line_item[:gross], 
            line_item[:tare], line_item[:net], line_item[:price], line_item[:amount])
        else
          # Update existing item
          Ticket.update_item(current_user.token, current_yard_id, params[:id], line_item[:id], line_item[:commodity], line_item[:gross], 
            line_item[:tare], line_item[:net], line_item[:price], line_item[:amount])
        end
      end
      @ticket = "true"
      ### Save Ticket ###
      if params[:save]
        @ticket = Ticket.update(current_user.token, current_yard_id, ticket_params[:customer_id], params[:id], ticket_params[:ticket_number], ticket_params[:status])
      ### End Save Ticket ###
      ### Close Ticket ###
      elsif params[:close_ticket]
        @ticket = Ticket.update(current_user.token, current_yard_id, ticket_params[:customer_id], params[:id], ticket_params[:ticket_number], 1)
      ### End Close Ticket ###
      ### Pay Ticket ###
      elsif params[:pay_ticket]
        Ticket.update(current_user.token, current_yard_id, ticket_params[:customer_id], params[:id], ticket_params[:ticket_number], ticket_params[:status])
        @accounts_payable_items = Ticket.accounts_payable_items(current_user.token, current_yard_id, params[:id])
        if params[:checking_account_payment] and params[:checking_account_payment][:id]
          @ticket = Ticket.pay_by_check(current_user.token, current_yard_id, params[:id], @accounts_payable_items.last['Id'], params[:drawer_id], 
            params[:checking_account_payment][:id], params[:checking_account_payment][:name], params[:checking_account_payment][:check_number], params[:payment_amount])
        else
          @ticket = Ticket.pay_by_cash(current_user.token, current_yard_id, params[:id], @accounts_payable_items.last['Id'], params[:drawer_id], params[:payment_amount])
        end
      ### End Pay Ticket ###
      ### Close & Pay Ticket ###
      elsif params[:close_and_pay_ticket]
        Ticket.update(current_user.token, current_yard_id, ticket_params[:customer_id], params[:id], ticket_params[:ticket_number], 1)
        @accounts_payable_items = Ticket.accounts_payable_items(current_user.token, current_yard_id, params[:id])
        if params[:checking_account_payment] and params[:checking_account_payment][:id]
          @ticket = Ticket.pay_by_check(current_user.token, current_yard_id, params[:id], @accounts_payable_items.last['Id'], params[:drawer_id], 
          params[:checking_account_payment][:id], params[:checking_account_payment][:name], params[:checking_account_payment][:check_number], params[:payment_amount])
        else
          @ticket = Ticket.pay_by_cash(current_user.token, current_yard_id, params[:id], @accounts_payable_items.last['Id'], params[:drawer_id], params[:payment_amount])
        end
      ### End Close & Pay Ticket ###
      else
        @ticket = Ticket.update(current_user.token, current_yard_id, ticket_params[:customer_id], params[:id], ticket_params[:ticket_number], ticket_params[:status])
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
        redirect_to tickets_path
        }
    end
  end
  
  def line_item_fields
    @ticke_number = params[:ticket_number]
    respond_to do |format|
      format.js
    end
  end
  
  def void_item
    respond_to do |format|
      format.html {}
      format.json {
        @ticket = Ticket.void_item(current_user.token, current_yard_id, params[:ticket_id], params[:item_id], params[:commodity_id], params[:gross], 
          params[:tare], params[:net], params[:price], params[:amount])
        if @ticket == 'true'
          render json: {}, :status => :ok
        else
          render json: {}, status: :unprocessable_entity
        end
      }
    end
  end

  # DELETE /tickets/1
  # DELETE /tickets/1.json
  def destroy
    @ticket.destroy
    respond_to do |format|
      format.html { redirect_to tickets_url, notice: 'Ticket was successfully destroyed.' }
      format.json { head :no_content }
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
        redirect_to tickets_path(status: '3') 
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
      params.require(:ticket).permit(:ticket_number, :customer_id, :id, :status, line_items: [:id, :commodity, :gross, :tare, :net, :price, :amount, :status])
    end
end
