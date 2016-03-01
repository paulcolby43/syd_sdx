class TicketsController < ApplicationController
  before_filter :login_required
#  before_action :set_ticket, only: [:show, :edit, :update, :destroy]

  # GET /tickets
  # GET /tickets.json
  def index
    @status = "#{params[:status].blank? ? 'held' : params[:status]}"
#    @next_number = Ticket.next_available_number(current_token, current_yard_id)
#    @uom = Ticket.units_of_measure(current_token)
#    Ticket.create(current_token, current_yard_id)
    
    unless params[:q].blank?
      results = Ticket.search(@status, current_token, current_yard_id, params[:q])
    else
      results = Ticket.all(@status, current_token, current_yard_id)
    end
    unless results.blank?
      results = results.reverse if @status == 'held'
      @tickets = Kaminari.paginate_array(results).page(params[:page]).per(10)
    else
      @tickets = []
    end
  end

  # GET /tickets/1
  # GET /tickets/1.json
  def show
    @ticket = Ticket.find_by_id(params[:status], current_token, params[:yard_id], params[:id])
  end

  # GET /tickets/new
  def new
#    @ticket = Ticket.new
    if @ticket_number.blank?
      @ticket_number = Ticket.next_available_number(current_token, current_yard_id)
    end
    @guid = SecureRandom.uuid
  end

  # POST /tickets
  # POST /tickets.json
#  def create
##    @ticket = Ticket.new(ticket_params)
#    @ticket = Ticket.create(current_token, current_yard_id, ticket_params[:customer_id], ticket_params[:ticket_number], ticket_params[:id])
#
#    respond_to do |format|
#      logger.debug "**************ticket success response: #{@ticket}"
#      if @ticket == 'true'
##        format.html { redirect_to @ticket, notice: 'Ticket was successfully created.' }
#        format.html {
#          flash[:success] = 'Ticket was successfully created.'
#          redirect_to tickets_path
#        }
#        format.json { render :show, status: :created, location: @ticket }
#      else
#        format.html { 
#          flash.now[:danger] = 'Error creating ticket.'
#          render :new, locals: {customer_id: ticket_params[:customer_id], ticket_number: ticket_params[:ticket_number]}
#          }
#        format.json { render json: @ticket.errors, status: :unprocessable_entity }
#      end
#    end
#  end
  
  # GET /tickets/1/edit
  def edit
    @ticket = Ticket.find_by_id(params[:status], current_token, current_yard_id, params[:id])
    @commodities = Commodity.all(current_token, current_yard_id)
  end

  # PATCH/PUT /tickets/1
  # PATCH/PUT /tickets/1.json
  def update
    respond_to do |format|
      ticket_params[:line_items].each do |line_item|
        if line_item[:status].blank?
          # Create new item
          @ticket = Ticket.add_item(current_token, current_yard_id, params[:id], line_item[:commodity], line_item[:gross], 
            line_item[:tare], line_item[:net], line_item[:price], line_item[:amount])
        else
          # Update existing item
          @ticket = Ticket.update_item(current_token, current_yard_id, params[:id], line_item[:id], line_item[:commodity], line_item[:gross], 
            line_item[:tare], line_item[:net], line_item[:price], line_item[:amount])
        end
      end
      if params[:close_ticket]
        Ticket.update(current_token, current_yard_id, ticket_params[:id], 'Closed')
      end
      if @ticket == 'true'
        format.html { 
          flash[:success] = 'Ticket was successfully updated.'
          redirect_to tickets_path 
          }
      else
        format.html { 
          flash[:danger] = 'Error updating ticket.'
          redirect_to tickets_path
#          render :edit, locals: {ticket_number: @ticket['TicketNumber']}
          }
      end
#      if @ticket.update(ticket_params)
#        format.html { redirect_to @ticket, notice: 'Ticket was successfully updated.' }
#        format.json { render :show, status: :ok, location: @ticket }
#      else
#        format.html { render :edit }
#        format.json { render json: @ticket.errors, status: :unprocessable_entity }
#      end
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
        @ticket = Ticket.void_item(current_token, current_yard_id, params[:item_id])
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
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ticket_params
      params.require(:ticket).permit(:ticket_number, :customer_id, :id, line_items: [:id, :commodity, :gross, :tare, :net, :price, :amount, :status])
    end
end
