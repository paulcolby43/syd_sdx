class PackContractsController < ApplicationController
  before_filter :login_required  

  # GET /pack_contracts
  # GET /pack_contracts.json
  def index
    authorize! :index, :pack_contracts
#    @query_string = params[:q].blank? ? '' : "%#{params[:q]}%"
    @pack_contracts = Kaminari.paginate_array(PackContract.all(current_user.token, current_yard_id, params[:q])).page(params[:page]).per(10)
  end

  # GET /pack_contracts/1
  # GET /pack_contracts/1.json
  def show
    authorize! :show, :pack_contracts
    @pack_contract = PackContract.find_by_contract_number(current_user.token, current_yard_id, params[:contract_number])
    @pack_lists = PackList.all(current_user.token, current_yard_id, @pack_contract['Id'])
    respond_to do |format|
      format.html {}
      format.json {render json: {"name" => @pack_contract['BillToCompany']} } 
    end
  end

  # GET /pack_contracts/new
  def new
  end

  # GET /pack_contracts/1/edit
  def edit
    authorize! :edit, :pack_contracts
    @status = "#{params[:status].blank? ? '0' : params[:status]}"
    @pack_contract = PackContract.find_by_id(current_user.token, current_yard_id, @status, params[:id])
  end

  # POST /pack_contracts
  # POST /pack_contracts.json
  def create
    @pack_contract = PackContract.new(pack_contract_params)

    respond_to do |format|
      if @pack_contract.save
        format.html { 
          flash[:success] = 'PackContract was successfully created.'
          redirect_to edit_user_setting_path(current_user.user_setting)
#          redirect_to @pack_contract
        }
        format.json { render :show, status: :created, location: @pack_contract }
      else
        format.html { render :new }
        format.json { render json: @pack_contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pack_contracts/1
  # PATCH/PUT /pack_contracts/1.json
  def update
    @pack_contract = PackContract.update(current_user.token, current_yard_id, pack_contract_params)
    respond_to do |format|
      format.html {
        if @pack_contract == 'true'
          flash[:success] = 'PackContract List was successfully updated.'
        else
          flash[:danger] = 'Error updating PackContract List.'
        end
        redirect_to pack_contracts_path
      }
    end
  end

  # DELETE /pack_contracts/1
  # DELETE /pack_contracts/1.json
  def destroy
    @pack_contract.destroy
    respond_to do |format|
      format.html { redirect_to pack_contracts_url, notice: 'PackContract was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pack_contract
      @pack_contract = PackContract.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pack_contract_params
      params.require(:pack_contract).permit(:id, :description, :quantity, :net)
    end
end
