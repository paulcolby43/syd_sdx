class ContractsController < ApplicationController
  before_filter :login_required  
  load_and_authorize_resource

  # GET /contracts
  # GET /contracts.json
  def index
#    @contracts = current_user.contracts
    @contract = Yard.contract(current_yard_id)
  end

  # GET /contracts/1
  # GET /contracts/1.json
  def show
  end

  # GET /contracts/new
  def new
  end

  # GET /contracts/1/edit
  def edit
  end

  # POST /contracts
  # POST /contracts.json
  def create
    @contract = Contract.new(contract_params)

    respond_to do |format|
      if @contract.save
        format.html { 
          flash[:success] = 'Contract was successfully created.'
          redirect_to edit_user_setting_path(current_user.user_setting)
#          redirect_to @contract
        }
        format.json { render :show, status: :created, location: @contract }
      else
        format.html { render :new }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contracts/1
  # PATCH/PUT /contracts/1.json
  def update
    respond_to do |format|
      if @contract.update(contract_params)
        format.html { 
          flash[:success] = 'Contract was successfully updated.'
          redirect_to edit_user_setting_path(current_user.user_setting)
#          redirect_to @contract
          }
        format.json { render :show, status: :ok, location: @contract }
      else
        format.html { render :edit }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contracts/1
  # DELETE /contracts/1.json
  def destroy
    @contract.destroy
    respond_to do |format|
      format.html { redirect_to contracts_url, notice: 'Contract was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contract
      @contract = Contract.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contract_params
      params.require(:contract).permit(:contract_id, :contract_name, :text1, :text2, :text3, :text4)
    end
end
