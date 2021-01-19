class V2::TicketsController < ApplicationController
  before_filter :login_required
  
  # GET /tickets
  # GET /tickets.json
  def index
    @status = "#{(params[:status].blank? or current_user.mobile_inspector?) ? 'HOLD' : params[:status]}"
    @start_date = params[:start_date].blank? ? Date.today.last_week.to_s : params[:start_date]
    @end_date = params[:end_date].blank? ? Date.today.to_s : params[:end_date]
    @ticket_number_query = params[:q]
#    @sort_column = params[:sort_column] ||= 'DateCreated'
#    @sort_direction = params[:sort_direction] ||= @status == 'PAID' ? 'Descending' : 'Ascending'
#    response = DRAGONQLAPI::Client.query(IndexQuery, variables: {ticketStatus: @status, startDate: @start_date, endDate: @end_date})
    if @ticket_number_query.blank?
      filter = ' {"ticketStatus": {"eq": "' + @status + '"}, "and": [{"dateCreated": {"gte": "' +  @start_date + '" }}, {"dateCreated": {"lte": "' + @end_date + '" }} ]} '
    else
      filter = ' {"ticketStatus": {"eq": "' + @status + '"}, "ticketNumber": {"eq": ' + @ticket_number_query + '}} '
    end
#    response = DRAGONQLAPI::Client.query(IndexQuery, variables: {ticket_head_filter_input: JSON[filter]})
#    response = Ticket.v2_all_by_filter(filter)
#    ticket_results = response.data.ticket_heads.nodes unless response.blank? or response.data.blank? or response.data.ticket_heads.blank?
    ticket_results = Ticket.v2_all_by_filter(filter)
#    @errors = response.data.errors unless response.blank? or response.data.blank? or response.data.errors.blank?
#    @currencies = Ticket.currencies(current_user.token)
    @tickets = Kaminari.paginate_array(ticket_results).page(params[:page]).per(10) unless ticket_results.blank?
    respond_to do |format|
      format.html { 
        if ticket_results.blank? and not @errors.blank?
          flash[:danger] = "Error searching tickets"
        end
      }
      format.json { 
        unless ticket_results.blank?
          render json: JSON.pretty_generate(ticket_results.as_json) 
        else
          render json: {message: "Error searching tickets"}, status: 400
        end
          }
      format.js {} #For endless page
    end
  end
  
  # GET /tickets/:id
  # GET /tickets/:id.json
  def show
#    response = Ticket.v2_find_by_id(params[:id])
#    @ticket = response.data.ticket_head_by_id unless response.blank? or response.data.blank? or response.data.ticket_head_by_id.blank?
    @ticket = Ticket.v2_find_by_id(params[:id])
    unless @ticket.blank?
      @images_array = Image.api_find_all_by_ticket_number(@ticket.ticket_number, current_user.company, @ticket.yard_id).reverse # Ticket images
    end
    respond_to do |format|
      format.html { 
        if @ticket.blank?
          flash[:danger] = "Not found."
          redirect_to root_path
        end
      }
      format.json { 
        unless @ticket.blank?
          render json: JSON.pretty_generate(@ticket.as_json) 
        else
          render json: { message: 'Not found.' }, status: :not_found
        end
        }
    end
  end
  
  # GET /tickets/:id/edit
  def edit
#    response = Ticket.v2_find_by_id(params[:id])
#    @ticket = response.data.ticket_head_by_id unless response.blank? or response.data.blank? or response.data.ticket_head_by_id.blank?
    @ticket = Ticket.v2_find_by_id(params[:id])
#    @drawers = Drawer.all(current_user.token, current_yard_id, current_user.currency_id)
    @drawers = Drawer.v2_find_all
#    @checking_accounts = CheckingAccount.all(current_user.token, current_yard_id)
    @checking_accounts = CheckingAccount.v2_find_all
    unless @ticket.blank?
      @images_array = Image.api_find_all_by_ticket_number(@ticket.ticket_number, current_user.company, @ticket.yard_id).reverse # Ticket images
    end
    @deductions_grouped_for_select = UserDefinedList.deductions_grouped_for_select(UserDefinedList.v2_deduct_reasons) 
    respond_to do |format|
      format.html { 
        if @ticket.blank?
          flash[:danger] = "Not found."
          redirect_to root_path
        end
      }
    end
  end

  private
   
    # Never trust parameters from the scary internet, only allow the white list through.
    def ticket_params
      params.require(:ticket).permit(:ticket_number, :customer_id, :id, :status, :description, :session_id, :related_workorder_id, :created_from_trip, 
        line_items: [:id, :commodity, :quantity, :gross, :tare, :net, :price,  :amount, :tax_amount, :status, :notes, :serial_number, :unit_of_measure, 
          :tax_amount_1, :tax_amount_2, :tax_amount_3, :tax_percent_1, :tax_percent_2, :tax_percent_3,
          deductions: [:deduct_weight_description, :deduct_weight, :deduct_dollar_amount_description, :deduct_dollar_amount, :id] ])
    end
end
