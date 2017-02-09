class ReportsController < ApplicationController
  before_filter :login_required
  #load_and_authorize_resource
  #before_action :set_report, only: [:show, :edit, :update]

  # GET /reports
  # GET /reports.json
  def index
    authorize! :index, :reports
    @type = report_params[:type] || 'customer_summary'
    @start_date = report_params[:start_date]
    @end_date = report_params[:end_date]
    unless @start_date.blank? and @end_date.blank?
      # Search all by date
      @tickets = Ticket.all_by_date(3, current_user.token, current_yard_id, @start_date, @end_date) unless current_user.customer?
      @tickets = Customer.paid_tickets_by_days(current_user.token, current_yard_id, current_user.customer_guid, 7) if current_user.customer?
    else
      # Search all today
      @tickets = Ticket.all_today(3, current_user.token, current_yard_id) unless current_user.customer?
      @tickets = Customer.paid_tickets_by_days(current_user.token, current_yard_id, current_user.customer_guid, 1) if current_user.customer?
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
    # Collect cash and check tickets
    @cash_payment_tickets = []
    @check_payment_tickets = []
    unless @tickets.blank?
      @tickets.each do |ticket|
        # Find accounts payable for this ticket and payment status of 1, then determine payment method
        accounts_payable = AccountsPayable.all(current_user.token, current_yard_id, ticket['Id']).find{|accounts_payable| accounts_payable['PaymentStatus'] == '1'}
        if accounts_payable['PaymentMethod'] == "0"
          @cash_payment_tickets << ticket
        elsif accounts_payable['PaymentMethod'] == "1"
          @check_payment_tickets << ticket
        end
      end
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
#      params.require(:report).permit(:start_date, :end_date, :type)
      params.fetch(:report, {}).permit(:start_date, :end_date, :type)
    end
end
