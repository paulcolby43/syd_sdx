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
      @tickets = Ticket.all_by_date(3, current_user.token, current_yard_id, @start_date, @end_date) 
    else
      # Search all today
      @tickets = Ticket.all_today(3, current_user.token, current_yard_id)
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
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
#      params.require(:report).permit(:start_date, :end_date, :type)
      params.fetch(:report, {}).permit(:start_date, :end_date, :type)
    end
end
