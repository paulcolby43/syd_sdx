class AccountsPayablesController < ApplicationController
  before_filter :login_required
#  before_action :set_accounts_payable, only: [:show, :edit, :update, :destroy]

  # GET /accounts_payables
  # GET /accounts_payables.json
  def index
    unless params[:q].blank?
      tickets = Ticket.search('Paid', current_token, current_yard_id, params[:q])
    else
      tickets = nil
    end
    unless tickets.blank?
      @accounts_payables = AccountsPayable.all(current_token, current_yard_id, tickets.last["Id"])
    else
      @accounts_payables = []
    end
    
  end

  # GET /accounts_payables/1
  # GET /accounts_payables/1.json
  def show
    @accounts_payable = AccountsPayable.find_by_id(current_token, current_yard_id, params[:ticket_id], params[:id])
#    @ticket = Ticket.find_ticket_number("Closed", current_token, current_yard_id, params[:ticket_id])
    respond_to do |format|
      format.html {}
      format.json { render :json => @accounts_payable }
    end
  end

  # GET /accounts_payables/new
  def new
    @accounts_payable = AccountsPayable.new
  end

  # GET /accounts_payables/1/edit
  def edit
    @accounts_payable = AccountsPayable.find_by_id(current_token, current_yard_id, params[:id])
  end

  # POST /accounts_payables
  # POST /accounts_payables.json
  def create
    @accounts_payable = AccountsPayable.new(accounts_payable_params)

    respond_to do |format|
      if @accounts_payable.save
        format.html { redirect_to @accounts_payable, notice: 'AccountsPayable was successfully created.' }
        format.json { render :show, status: :created, location: @accounts_payable }
      else
        format.html { render :new }
        format.json { render json: @accounts_payable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts_payables/1
  # PATCH/PUT /accounts_payables/1.json
  def update
    respond_to do |format|
      if @accounts_payable.update(accounts_payable_params)
        format.html { redirect_to @accounts_payable, notice: 'AccountsPayable was successfully updated.' }
        format.json { render :show, status: :ok, location: @accounts_payable }
      else
        format.html { render :edit }
        format.json { render json: @accounts_payable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts_payables/1
  # DELETE /accounts_payables/1.json
  def destroy
    @accounts_payable.destroy
    respond_to do |format|
      format.html { redirect_to accounts_payables_url, notice: 'AccountsPayable was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def create_ticket
    @accounts_payable = AccountsPayable.find_by_id(current_token, current_yard_id, params[:id])
#    @ticket_number = Ticket.next_available_number(current_token, current_yard_id)
    @guid = SecureRandom.uuid
    @ticket = Ticket.create(current_token, current_yard_id, @accounts_payable['Id'], @guid)
    respond_to do |format|
      format.html { 
        flash[:success] = 'Ticket was successfully created.'
        redirect_to edit_ticket_path(@guid, status: 'held') 
        }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_accounts_payable
      @accounts_payable = AccountsPayable.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def accounts_payable_params
      params.require(:accounts_payable).permit(:accounts_payablename)
    end
end
