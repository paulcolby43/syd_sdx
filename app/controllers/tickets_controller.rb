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
#    @ticket = Ticket.find_by_id_and_ticket_number(params[:status], current_token, current_yard_id, params[:id], params[:ticket_number])
    @ticket = Ticket.find_by_id(params[:status], current_token, current_yard_id, params[:id])
  end

  # GET /tickets/new
  def new
#    @ticket = Ticket.new
    if @ticket_number.blank?
      @ticket_number = Ticket.next_available_number(current_token, current_yard_id)
    end
    @guid = SecureRandom.uuid
  end

  # GET /tickets/1/edit
  def edit
    @drawers = Drawer.all(current_token, current_yard_id)
    @checking_accounts = CheckingAccount.all(current_token, current_yard_id)
#    @ticket = Ticket.find_by_id(params[:status], current_token, current_yard_id, params[:id])
    @ticket = Ticket.find_by_id(params[:status], current_token, current_yard_id, params[:id])
    @accounts_payable_items = AccountsPayable.all(current_token, current_yard_id, params[:id])
    @ticket_number = @ticket["TicketNumber"]
    @line_items = @ticket["TicketItemCollection"]["ApiTicketItem"].select {|i| i["Status"] == 'Closed'} unless @ticket["TicketItemCollection"].blank?
    @commodities = Commodity.all(current_token, current_yard_id)
    @images = Image.where(ticket_nbr: @ticket["TicketNumber"], yardid: current_yard_id)
  end

  # PATCH/PUT /tickets/1
  # PATCH/PUT /tickets/1.json
  def update
    respond_to do |format|
#      @drawers = Drawer.all(current_token, current_yard_id)
      ticket_params[:line_items].each do |line_item|
        if line_item[:status].blank?
          # Create new item
          Ticket.add_item(current_token, current_yard_id, params[:id], line_item[:commodity], line_item[:gross], 
            line_item[:tare], line_item[:net], line_item[:price], line_item[:amount])
        else
          # Update existing item
          Ticket.update_item(current_token, current_yard_id, params[:id], line_item[:id], line_item[:commodity], line_item[:gross], 
            line_item[:tare], line_item[:net], line_item[:price], line_item[:amount])
        end
      end
      @ticket = "true"
      ### Close Ticket ###
      if params[:close_ticket]
        @ticket = Ticket.update(current_token, current_yard_id, ticket_params[:customer_id], params[:id], ticket_params[:ticket_number], 1)
      end
      ### End Close Ticket ###
      ### Pay Ticket ###
      if params[:pay_ticket]
        if params[:checking_account_payment][:id]
          @ticket = Ticket.pay_by_check(current_token, current_yard_id, params[:id], params[:accounts_payable_id], params[:drawer_id], 
            params[:checking_account_payment][:id], params[:checking_account_payment][:name], params[:checking_account_payment][:check_number], params[:payment_amount])
        else
          @ticket = Ticket.pay_by_cash(current_token, current_yard_id, params[:id], params[:accounts_payable_id], params[:drawer_id], params[:payment_amount])
        end
      end
      ### End Pay Ticket ###
      ### Close & Pay Ticket ###
      if params[:close_and_pay_ticket]
        @ticket = Ticket.update(current_token, current_yard_id, ticket_params[:customer_id], params[:id], ticket_params[:ticket_number], 1)
        @accounts_payable_items = Ticket.acccounts_payable_items(current_token, current_yard_id, params[:id])
        if params[:checking_account_payment][:id]
          @ticket = Ticket.pay_by_check(current_token, current_yard_id, params[:id], @accounts_payable_items.last['Id'], params[:drawer_id], 
          params[:checking_account_payment][:id], params[:checking_account_payment][:name], params[:checking_account_payment][:check_number], params[:payment_amount])
        else
          @ticket = Ticket.pay_by_cash(current_token, current_yard_id, params[:id], @accounts_payable_items.last['Id'], params[:drawer_id], params[:payment_amount])
        end
      end
      ### End Close & Pay Ticket ###
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
        @ticket = Ticket.void_item(current_token, current_yard_id, params[:ticket_id], params[:item_id], params[:commodity_id], params[:gross], 
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
