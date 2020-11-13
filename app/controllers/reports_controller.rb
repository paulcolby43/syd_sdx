class ReportsController < ApplicationController
  before_filter :login_required
  #load_and_authorize_resource
  #before_action :set_report, only: [:show, :edit, :update]
  
  helper_method :sort_column, :sort_direction

  # GET /reports
  # GET /reports.json
  def index
    authorize! :index, :reports
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
    @sort_column = sort_column
    @sort_direction = sort_direction
    @start_date = report_params[:start_date].blank? ? Date.today.to_s : report_params[:start_date]# Default to today
    @end_date = report_params[:end_date].blank? ? Date.today.to_s : report_params[:end_date]# Default to today
    @customer_user = User.where(customer_guid: params[:customer_id], yard_id: current_yard_id).last # Look for customer user if admin is viewing through iframe on customer show page
    @user = @customer_user.blank? ? current_user : @customer_user
    @pack_shipments = PackShipment.all_by_date_and_customers(current_user.token, current_yard_id, @start_date, @end_date, @user.portal_customer_ids) if (current_user.customer? or @customer_user.present?)
    @pack_shipments = PackShipment.all_by_date(current_user.token, current_yard_id, @start_date, @end_date) unless (current_user.customer? or @customer_user.present?)
    
    respond_to do |format|
      format.html {}
      format.csv { 
        send_data PackShipment.customer_summary_to_csv(@pack_shipments), filename: "shipments-report-#{@start_date}-#{@end_date}.csv" 
      }
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
#      params.require(:report).permit(:start_date, :end_date, :type)
      params.fetch(:report, {}).permit(:start_date, :end_date, :type, :status)
    end
    
    ### Secure the shipments sort direction ###
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    ### Secure the shipments sort column name ###
    def sort_column
      ["DateShipped", "ShipmentNumber", "ContractDescription", "Material", "ShipmentType", "OrderNumber", "BookingNumber", "SealNumber", "GrossWeight", "TareWeight", "NetWeight"].include?(params[:sort]) ? params[:sort] : "DateShipped"
    end
end
