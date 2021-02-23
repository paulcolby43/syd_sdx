class V2::ReportsController < ApplicationController
  before_filter :login_required
  #load_and_authorize_resource
  #before_action :set_report, only: [:show, :edit, :update]
  
  include ActionController::Streaming
  include Zipline
  
  helper_method :shipment_sort_column, :sort_direction, :ticket_sort_column

  # GET v2/reports
  # GET v2/reports.json
  def index
    authorize! :index, :reports
    @sort_column = ticket_sort_column
    @sort_direction = sort_direction
    @status = "#{report_params[:status].blank? ? '3,1' : report_params[:status]}" # Default status to 1 (closed tickets)
    @type = report_params[:type] || 'commodity_summary' # Default to commodity summary
    @start_date = report_params[:start_date].blank? ? Date.today.to_s : report_params[:start_date]# Default to today
    @end_date = report_params[:end_date].blank? ? Date.today.to_s : report_params[:end_date]# Default to today
    @customer_user = User.where(customer_guid: params[:customer_id], yard_id: current_yard_id).last # Look for customer user if admin is viewing through iframe on customer show page
    @user = @customer_user.blank? ? current_user : @customer_user
    unless @status == 'shipments'
      # Tickets report
      if current_user.customer? or @customer_user.present?
        if params[:q].blank?
          tickets = Ticket.all_by_date_and_customers(@status.split(',').map(&:to_i), @user.token, current_yard_id, @start_date, @end_date, @user.portal_customer_ids) 
          unless tickets.blank?
            @tickets = tickets.select {|t| t['Status'] != '7'} # Only show tickets not awaiting approval status
          else
            @tickets = nil
          end
        else
          tickets = Ticket.search_all_statuses(@user.token, current_yard_id, params[:q])
          unless tickets.blank?
            @tickets = tickets.select {|t| @user.portal_customer_ids.include?(t["CustomerId"]) and t['Status'] != '7'} # Only show tickets this customer portal user has access to and not awaiting approval status
          else
            @tickets = nil
          end
        end
      else
        @tickets = Ticket.all_by_date_and_status_and_yard(@status.split(',').map(&:to_i), current_user.token, current_yard_id, @start_date, @end_date)
      end
      @line_items = []
      unless @tickets.blank?
        @tickets.each do |ticket|
          unless ticket['TicketItemCollection'].blank? or ticket['TicketItemCollection']['ApiTicketItem'].blank?
            @line_items = @line_items + Ticket.line_items(ticket['TicketItemCollection']['ApiTicketItem'])
          end
        end
      end
      @line_items_total = 0
      @line_items.each do |line_item|
        @line_items_total = @line_items_total + line_item["ExtendedAmount"].to_d
      end
      # Collect cash, check, and ezcash tickets
      @cash_payment_tickets = []
      @check_payment_tickets = []
      @ezcash_payment_tickets = []
      unless @tickets.blank? or @status == '1' # Don't look for accounts payable for each ticket if there aren't any, or if showing closed tickets
        @tickets.each do |ticket|
          if ticket['Status']  == '3' # Do this only for paid tickets
            # Find accounts payable for this ticket and payment status of 1, then determine payment method
            accounts_payable = AccountsPayable.all(current_user.token, current_yard_id, ticket['Id']).find{|accounts_payable| accounts_payable['PaymentStatus'] == '1'}
            if accounts_payable and accounts_payable['PaymentMethod'] == "0"
              @cash_payment_tickets << ticket
            elsif accounts_payable and accounts_payable['PaymentMethod'] == "1"
              @check_payment_tickets << ticket
            elsif accounts_payable and accounts_payable['PaymentMethod'] == "3"
              @ezcash_payment_tickets << ticket
            else
              @cash_payment_tickets << ticket
            end
          end
        end
      end
      @cash_total = 0
      @cash_payment_tickets.each do |cash_payment_ticket|
        unless cash_payment_ticket['TicketItemCollection'].blank? or cash_payment_ticket['TicketItemCollection']['ApiTicketItem'].blank?
          @cash_total = @cash_total + Ticket.line_items_total(cash_payment_ticket['TicketItemCollection']['ApiTicketItem']).to_d
        end
      end
      @check_total = 0
      @check_payment_tickets.each do |check_payment_ticket|
        unless check_payment_ticket['TicketItemCollection'].blank? or check_payment_ticket['TicketItemCollection']['ApiTicketItem'].blank?
          @check_total = @check_total + Ticket.line_items_total(check_payment_ticket['TicketItemCollection']['ApiTicketItem']).to_d
        end
      end
      @ezcash_total = 0
      @ezcash_payment_tickets.each do |ezcash_payment_ticket|
        unless ezcash_payment_ticket['TicketItemCollection'].blank? or ezcash_payment_ticket['TicketItemCollection']['ApiTicketItem'].blank?
          @ezcash_total = @ezcash_total + Ticket.line_items_total(ezcash_payment_ticket['TicketItemCollection']['ApiTicketItem']).to_d
        end
      end
#      @cash_total = @cash_payment_tickets.map { |t| Ticket.line_items_total(t['TicketItemCollection']['ApiTicketItem']).to_d }.sum
#      @check_total = @check_payment_tickets.map { |t| Ticket.line_items_total(t['TicketItemCollection']['ApiTicketItem']).to_d }.sum
#      @ezcash_total = @ezcash_payment_tickets.map { |t| Ticket.line_items_total(t['TicketItemCollection']['ApiTicketItem']).to_d }.sum
    else
      # Shipments report
      # Just show customer summary report
      @type = 'customer_summary'
      @pack_shipments = PackShipment.all_by_date_and_customers(current_user.token, current_yard_id, @start_date, @end_date, @user.portal_customer_ids) if (current_user.customer? or @customer_user.present?)
      @pack_shipments = PackShipment.all_by_date(current_user.token, current_yard_id, @start_date, @end_date) unless (current_user.customer? or @customer_user.present?)
    end
    
    respond_to do |format|
      format.html {
      }
      format.csv { 
        unless @status == 'shipments'
          if @type == "customer_summary"
            send_data Ticket.customer_summary_to_csv(@tickets), filename: "customer-summary-report-#{@start_date}-#{@end_date}.csv" 
          else
            send_data Ticket.commodity_summary_to_csv(@line_items, @tickets), filename: "commodity-summary-report-#{@start_date}-#{@end_date}.csv"
          end
        else
          if @type == "customer_summary"
            send_data PackShipment.customer_summary_to_csv(@pack_shipments), filename: "customer-summary-report-#{@start_date}-#{@end_date}.csv" 
          else
            send_data PackShipment.commodity_summary_to_csv(@pack_lists), filename: "commodity-summary-report-#{@start_date}-#{@end_date}.csv"
          end
        end
      }
    end
    
  end
  
  def telerik
    @cashier_id = params[:cashier_id]
  end
  
  def shipments
    authorize! :index, :reports
    @sort_column = shipment_sort_column
    @sort_direction = sort_direction
    @start_date = report_params[:start_date].blank? ? Date.today.to_s : report_params[:start_date]# Default to today
    @end_date = report_params[:end_date].blank? ? Date.today.to_s : report_params[:end_date]# Default to today
    @q = params[:q]
    @customer_user = User.where(customer_guid: params[:customer_id], yard_id: current_yard_id).last # Look for customer user if admin is viewing through iframe on customer show page
    @user = @customer_user.blank? ? current_user : @customer_user
    unless params[:q].blank?
      if current_user.customer? or @customer_user.present?
        filter = ' {"customerId": {"in": ' + "#{@user.portal_customer_ids}" + '}, "and": [{"dateShipped": {"gte": "' +  @start_date + '" }}, {"dateShipped": {"lte": "' + @end_date + '" }} ], "or": [{"shipmentNumber": {"eq": ' +  "#{@q.to_i}" + '}}, {"bookingNumber": {"eq": "' +  @q + '" }}, {"containerNumber": {"eq": "' +  @q + '" }} ]} '
      else
        filter = ' {"and": [{"dateShipped": {"gte": "' +  @start_date + '" }}, {"dateShipped": {"lte": "' + @end_date + '" }} ], "or": [{"shipmentNumber": {"eq": ' +  "#{@q.to_i}" + '}}, {"bookingNumber": {"eq": "' +  @q + '" }}, {"containerNumber": {"eq": "' +  @q + '" }} ]} '
      end
    else
      if current_user.customer? or @customer_user.present?
        filter = ' {"customerId": {"in": ' + "#{@user.portal_customer_ids}" + '}, "and": [{"dateShipped": {"gte": "' +  @start_date + '" }}, {"dateShipped": {"lte": "' + @end_date + '" }} ]} '
      else
        filter = ' {"and": [{"dateShipped": {"gte": "' +  @start_date + '" }}, {"dateShipped": {"lte": "' + @end_date + '" }} ]} '
      end
    end
    Rails.logger.debug "**********filter: #{filter}"
    @pack_shipments = PackShipment.v2_all_by_filter(filter)
    
#    @pack_shipments = PackShipment.all_by_date_and_customers(current_user.token, current_yard_id, @start_date, @end_date, @user.portal_customer_ids) if (current_user.customer? or @customer_user.present?)
#    @pack_shipments = PackShipment.all_by_date(current_user.token, current_yard_id, @start_date, @end_date) unless (current_user.customer? or @customer_user.present?)
#    unless @q.blank?
#      @pack_shipments = PackShipment.shipments_search(@pack_shipments, @q)
#    end
    respond_to do |format|
      format.html {}
      format.csv { 
        send_data PackShipment.v2_customer_summary_to_csv(@pack_shipments), filename: "shipments-report-#{@start_date}-#{@end_date}.csv" 
      }
      format.zip {
        @images_array = []
        @pack_shipments.each do |pack_shipment|
          if current_user.customer? and not current_user.customer_guid.blank?
            @images_array = @images_array + Shipment.api_find_all_by_shipment_number(pack_shipment.shipment_number, current_user.company, pack_shipment.yard_id).reverse # Shipment images
          else
            @images_array = @images_array +  Shipment.api_find_all_by_shipment_number(pack_shipment.shipment_number, current_user.company, current_yard_id).reverse # Shipment images
          end
        end
        require 'open-uri'
        files = @images_array.map{ |image| [Shipment.jpeg_image_url(current_user.company, image['CAPTURE_SEQ_NBR'], current_yard_id), "shipment_#{image['TICKET_NBR']}/booking_#{image['BOOKING_NBR']}_container_#{image['CONTAINER_NBR']}_#{image['EVENT_CODE']}_#{image['CAPTURE_SEQ_NBR']}.jpg"]}
        name = "shipments-images-report-#{@start_date}-#{@end_date}"
        file_mappings = files
        .lazy  # Lazy allows us to begin sending the download immediately instead of waiting to download everything
        .map { |url, path| [open(url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}), path] }
        zipline(file_mappings, "#{name}.zip")
      }
    end
  end
  
  def tickets
    authorize! :index, :reports
    @sort_column = ticket_sort_column
    @sort_direction = sort_direction
    @status = "#{report_params[:closed].blank? ? '' : report_params[:closed] + ','}#{report_params[:paid].blank? ? '' : report_params[:paid] + ','}#{report_params[:held].blank? ? '' : report_params[:held]}"
    if @status.blank?
#      @status = '3,1'
      @status = 'CLOSED,PAID'
    end
    @type = report_params[:type] || 'commodity_summary' # Default to commodity summary
    @commodity = report_params[:commodity] if @type == 'commodity_summary'
    @customer = report_params[:customer] if @type == 'customer_summary'
    @start_date = report_params[:start_date].blank? ? Date.today.to_s : report_params[:start_date]# Default to today
    @end_date = report_params[:end_date].blank? ? Date.today.to_s : report_params[:end_date]# Default to today
    @customer_user = User.where(customer_guid: params[:customer_id], yard_id: current_yard_id).last # Look for customer user if admin is viewing through iframe on customer show page
    @user = @customer_user.blank? ? current_user : @customer_user
    
    if current_user.customer? or @customer_user.present?
      filter = ' {"customerId": {"in": ' + "#{@user.portal_customer_ids}" + '}, "ticketStatus": {"in": ' + "#{@status.split(',').map(&:to_s)}" + '}, "and": [{"dateCreated": {"gte": "' +  @start_date + '" }}, {"dateCreated": {"lte": "' + @end_date + '" }} ]} '
    else
      filter = ' {"ticketStatus": {"in": ' + "#{@status.split(',').map(&:to_s)}" + '}, "and": [{"dateCreated": {"gte": "' +  @start_date + '" }}, {"dateCreated": {"lte": "' + @end_date + '" }} ]} '
    end
    @ticket_results = Ticket.v2_all_by_filter(filter)
    @tickets = @ticket_results
    
    @line_items = []
    unless @tickets.blank?
      @tickets.each do |ticket|
        unless ticket.ticket_items.blank?
          @line_items = @line_items + ticket.ticket_items
        end
      end
    end
    @line_items_total = 0
    @line_items.each do |line_item|
      @line_items_total = @line_items_total + line_item.extended_amount.to_d
    end
    # Collect cash, check, and ezcash tickets
    @cash_payment_tickets = []
    @check_payment_tickets = []
    @ezcash_payment_tickets = []
    unless @tickets.blank? or @status == '1' # Don't look for accounts payable for each ticket if there aren't any, or if showing closed tickets
      @tickets.each do |ticket|
        if ticket.ticket_status  == 'PAID' # Do this only for paid tickets
          # Find accounts payable for this ticket and payment status of 1, then determine payment method
          accounts_payable = ticket.account_payable_line_items.first unless ticket.account_payable_line_items.blank?
          if accounts_payable and accounts_payable.payment_method == 'CASH'
            @cash_payment_tickets << ticket
          elsif accounts_payable and accounts_payable.payment_method == 'CHECK'
            @check_payment_tickets << ticket
          elsif accounts_payable and accounts_payable.payment_method == 'EZ_CASH'
            @ezcash_payment_tickets << ticket
          else
            @cash_payment_tickets << ticket
          end
        end
      end
    end
    @cash_total = 0
    @cash_payment_tickets.each do |cash_payment_ticket|
      unless cash_payment_ticket.ticket_items.blank?
        @cash_total = @cash_total + Ticket.v2_line_items_total(cash_payment_ticket.ticket_items).to_d
      end
    end
    @check_total = 0
    @check_payment_tickets.each do |check_payment_ticket|
      unless check_payment_ticket.ticket_items.blank?
        @check_total = @check_total + Ticket.v2_line_items_total(check_payment_ticket.ticket_items).to_d
      end
    end
    @ezcash_total = 0
    @ezcash_payment_tickets.each do |ezcash_payment_ticket|
      unless ezcash_payment_ticket.ticket_items.blank?
        @ezcash_total = @ezcash_total + Ticket.v2_line_items_total(ezcash_payment_ticket.ticket_items).to_d
      end
    end
    
    respond_to do |format|
      format.html {}
      format.csv { 
        if @type == "customer_summary"
          send_data Ticket.v2_customer_summary_to_csv(@tickets), filename: "customer-summary-report-#{@start_date}-#{@end_date}.csv" 
        else
          send_data Ticket.v2_commodity_summary_to_csv(@line_items), filename: "commodity-summary-report-#{@start_date}-#{@end_date}.csv"
        end
      }
      format.zip {
        @images_array = []
        @tickets.each do |ticket|
          if current_user.customer? and not current_user.customer_guid.blank?
            @images_array = @images_array + Image.api_find_all_by_ticket_number(ticket["TicketNumber"], current_user.company, ticket["YardId"]).reverse # Ticket images
          else
            @images_array = @images_array +  Image.api_find_all_by_ticket_number(ticket["TicketNumber"], current_user.company, current_yard_id).reverse # Ticket images
          end
        end
        require 'open-uri'
        files = @images_array.map{ |image| [Image.jpeg_image_url(current_user.company, image['CAPTURE_SEQ_NBR'], current_yard_id), "ticket_#{image['TICKET_NBR']}/#{image['EVENT_CODE']}_#{image['CAPTURE_SEQ_NBR']}.jpg"]}
        name = "ticket-images-report-#{@start_date}-#{@end_date}"
        file_mappings = files
        .lazy  # Lazy allows us to begin sending the download immediately instead of waiting to download everything
        .map { |url, path| [open(url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}), path] }
        zipline(file_mappings, "#{name}.zip")
      }
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
#      params.require(:report).permit(:start_date, :end_date, :type)
      params.fetch(:report, {}).permit(:start_date, :end_date, :type, :status, :closed, :paid, :held, :commodity, :customer)
    end
    
    ### Secure the shipments sort direction ###
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    ### Secure the shipments sort column name ###
    def shipment_sort_column
      ["date_shipped", "shipment_number", "contract_description", "container_number", "material", "shipment_type", "order_number", "booking_number", "seal_number", "gross_weight", "tare_weight", "net_weight"].include?(params[:shipment_sort]) ? params[:shipment_sort] : "date_shipped"
    end
    
    def ticket_sort_column
      ["date_created", "ticket_number", "gross_weight", "tare_eight", "net_weight", "extended_amount", "ticket_status"].include?(params[:ticket_sort]) ? params[:ticket_sort] : "date_created"
    end
end
