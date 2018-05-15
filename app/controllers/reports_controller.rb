class ReportsController < ApplicationController
  before_filter :login_required
  #load_and_authorize_resource
  #before_action :set_report, only: [:show, :edit, :update]

  # GET /reports
  # GET /reports.json
  def index
    authorize! :index, :reports
    @status = "#{report_params[:status].blank? ? '1' : report_params[:status]}" # Default status to 1 (closed tickets)
    @type = report_params[:type] || 'commodity_summary' # Default to commodity summary
    @start_date = report_params[:start_date] ||= Date.today.to_s # Default to today
    @end_date = report_params[:end_date] ||= Date.today.to_s # Default to today
    unless @status == 'shipments'
      # Tickets report
      if current_user.customer?
        if params[:q].blank?
          @tickets = Ticket.all_by_date_and_customers(@status.split(',').map(&:to_i), current_user.token, current_yard_id, @start_date, @end_date, current_user.portal_customer_ids) 
        else
          tickets = Ticket.search_all_statuses(current_user.token, current_yard_id, params[:q])
          @tickets = tickets.select {|t| current_user.portal_customer_ids.include?(t["CustomerId"])} # Only show tickets this customer portal user has access to
        end
      else
        @tickets = Ticket.all_by_date_and_status_and_yard(@status.split(',').map(&:to_i), current_user.token, current_yard_id, @start_date, @end_date)
      end
      @line_items = []
      unless @tickets.blank?
        @tickets.each do |ticket|
          @line_items = @line_items + Ticket.line_items(ticket['TicketItemCollection']['ApiTicketItem'])
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
            if accounts_payable['PaymentMethod'] == "0"
              @cash_payment_tickets << ticket
            elsif accounts_payable['PaymentMethod'] == "1"
              @check_payment_tickets << ticket
            elsif accounts_payable['PaymentMethod'] == "3"
              @ezcash_payment_tickets << ticket
            end
          end
        end
      end
      @cash_total = @cash_payment_tickets.map { |t| Ticket.line_items_total(t['TicketItemCollection']['ApiTicketItem']).to_d }.sum
      @check_total = @check_payment_tickets.map { |t| Ticket.line_items_total(t['TicketItemCollection']['ApiTicketItem']).to_d }.sum
      @ezcash_total = @ezcash_payment_tickets.map { |t| Ticket.line_items_total(t['TicketItemCollection']['ApiTicketItem']).to_d }.sum
    else
      # Shipments report
      # Just show customer summary report
      @type = 'customer_summary'
      @pack_shipments = PackShipment.all_by_date_and_customers(current_user.token, current_yard_id, @start_date, @end_date, current_user.portal_customer_ids) if current_user.customer?
      @pack_shipments = PackShipment.all_by_date(current_user.token, current_yard_id, @start_date, @end_date) unless current_user.customer?
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

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
#      params.require(:report).permit(:start_date, :end_date, :type)
      params.fetch(:report, {}).permit(:start_date, :end_date, :type, :status)
    end
end
