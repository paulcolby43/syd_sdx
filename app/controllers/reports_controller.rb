class ReportsController < ApplicationController
  before_filter :login_required
  #load_and_authorize_resource
  #before_action :set_report, only: [:show, :edit, :update]

  # GET /reports
  # GET /reports.json
  def index
    authorize! :index, :reports
    @tickets = Ticket.all_this_week(3, current_token, current_yard_id) 
    @line_items = []
    unless @tickets.blank?
      @tickets.each do |ticket|
        @line_items = @line_items + Ticket.line_items(3, current_token, current_yard_id, ticket['Id'])
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
      params.require(:report).permit(:name, :dragon_api)
    end
end
