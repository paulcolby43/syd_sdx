class ReportsController < ApplicationController
  before_filter :login_required
  #load_and_authorize_resource
  #before_action :set_report, only: [:show, :edit, :update]

  # GET /reports
  # GET /reports.json
  def index
    results = Ticket.all_this_week(3, current_token, current_yard_id) 
#    @customer_tickets = Kaminari.paginate_array(results.uniq { |ticket| ticket['CustomerId'] }).page(params[:page]).per(3)
#    @tickets = results.uniq { |ticket| ticket['CustomerId'] }  
    @tickets = results
#    @customer_tickets_total = 0
#    @tickets.each do |ticket|
#      @customer_tickets_total = @customer_tickets_total + Customer.paid_tickets_total_this_week(current_token, current_yard_id, ticket['Company'])
#    end
#    @commodities = []
#    @tickets.each do |ticket|
#      @commodities = @commodities + Ticket.commodities(3, current_token, current_yard_id, ticket['Id'])
#    end
    
    @line_items = []
    @tickets.each do |ticket|
      @line_items = @line_items + Ticket.line_items(3, current_token, current_yard_id, ticket['Id'])
    end
    @line_items_total = 0
    @line_items.each do |line_item|
      @line_items_total = @line_items_total + line_item["ExtendedAmount"].to_d
    end
#    @commodities = @commodities.uniq { |commodity| commodity['PrintDescription'] }
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.require(:report).permit(:name, :dragon_api)
    end
end
