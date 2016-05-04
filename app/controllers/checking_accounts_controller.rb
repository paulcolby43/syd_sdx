class CheckingAccountsController < ApplicationController
  before_filter :login_required
#  before_action :set_checking_account, only: [:show, :edit, :update, :destroy]

  # GET /checking_accounts
  # GET /checking_accounts.json
  def index
    @checking_accounts = CheckingAccount.all(current_user.token, current_yard_id)
  end

  # GET /checking_accounts/1
  # GET /checking_accounts/1.json
  def show
    @checking_account = CheckingAccount.find_by_id(current_user.token, current_yard_id, params[:id])
    respond_to do |format|
      format.html {}
      format.json { render :json => @checking_account }
    end
  end

  # GET /checking_accounts/new
  def new
    @checking_account = CheckingAccount.new
  end

  # GET /checking_accounts/1/edit
  def edit
    @checking_account = CheckingAccount.find_by_id(current_user.token, current_yard_id, params[:id])
  end

  # POST /checking_accounts
  # POST /checking_accounts.json
  def create
    @checking_account = CheckingAccount.new(checking_account_params)

    respond_to do |format|
      if @checking_account.save
        format.html { redirect_to @checking_account, notice: 'CheckingAccount was successfully created.' }
        format.json { render :show, status: :created, location: @checking_account }
      else
        format.html { render :new }
        format.json { render json: @checking_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /checking_accounts/1
  # PATCH/PUT /checking_accounts/1.json
  def update
    respond_to do |format|
      if @checking_account.update(checking_account_params)
        format.html { redirect_to @checking_account, notice: 'CheckingAccount was successfully updated.' }
        format.json { render :show, status: :ok, location: @checking_account }
      else
        format.html { render :edit }
        format.json { render json: @checking_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checking_accounts/1
  # DELETE /checking_accounts/1.json
  def destroy
    @checking_account.destroy
    respond_to do |format|
      format.html { redirect_to checking_accounts_url, notice: 'CheckingAccount was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def create_ticket
    @checking_account = CheckingAccount.find_by_id(current_user.token, current_yard_id, params[:id])
#    @ticket_number = Ticket.next_available_number(current_user.token, current_yard_id)
    @guid = SecureRandom.uuid
    @ticket = Ticket.create(current_user.token, current_yard_id, @checking_account['Id'], @guid)
    respond_to do |format|
      format.html { 
        flash[:success] = 'Ticket was successfully created.'
        redirect_to edit_ticket_path(@guid, status: 'held') 
        }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_checking_account
      @checking_account = CheckingAccount.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def checking_account_params
      params.require(:checking_account).permit(:checking_accountname)
    end
end
