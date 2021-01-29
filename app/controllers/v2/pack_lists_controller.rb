class V2::PackListsController < ApplicationController
  before_filter :login_required  

  # GET v2/pack_lists
  # GET v2/pack_lists.json
  def index
    authorize! :index, :pack_lists
#    @pack_lists = current_user.pack_lists
#    @pack_lists = Yard.pack_lists(current_yard_id)
     @status = "#{params[:status].blank? ? '0' : params[:status]}"
#     @pack_lists = Kaminari.paginate_array(PackList.test_array).page(params[:page]).per(10)
    @pack_lists = Kaminari.paginate_array(PackList.all(current_user.token, current_yard_id, @status)).page(params[:page]).per(10)
  end

  # GET v2/pack_lists/1
  # GET v2/pack_lists/1.json
  def show
    authorize! :show, :pack_lists
    @contract_id = params[:contract_id]
    @contract_number = params[:contract_number]
    @pack_contract = PackContract.find_by_contract_number(current_user.token, current_yard_id, @contract_number)
#    @pack_list = PackList.find_by_id(current_user.token, current_yard_id, @contract_id, params[:id])
    @pack_list = PackList.find(current_user.token, current_yard_id, params[:id])
    unless @pack_list['Items'].is_a? Hash
      # Multiple material items
      @packs = @pack_list['Items']['PackListItemInformation']
    else
      # One material item
      @packs = [@pack_list['Items']]
    end
    respond_to do |format|
      format.html {}
      format.json {render json: {"name" => @pack_list['PrintDescription']} } 
    end
  end

  # GET v2/pack_lists/new
  def new
  end

  # GET v2/pack_lists/1/edit
  def edit
    authorize! :edit, :pack_lists
#    @contract_id = params[:contract_id]
#    @contract_number = params[:contract_number]
#    @pack_contract = PackContract.find_by_contract_number(current_user.token, current_yard_id, @contract_number)
#    @pack_list = PackList.find_by_id(current_user.token, current_yard_id, @contract_id, params[:id])
    @pack_list = PackList.find(current_user.token, current_yard_id, params[:id])
#    @packs = PackList.pack_items(current_user.token, current_yard_id, params[:id])
    unless @pack_list['Items'].blank?
      unless @pack_list['Items'].is_a? Hash
        # Multiple material items
        @packs = @pack_list['Items']['PackListItemInformation']
      else
        # One material item
        @packs = [@pack_list['Items']]
      end
    else
      @packs = []
    end
  end

  # POST v2/pack_lists
  # POST v2/pack_lists.json
  def create
    @pack_list = PackList.new(pack_list_params)

    respond_to do |format|
      if @pack_list.save
        format.html { 
          flash[:success] = 'PackList was successfully created.'
          redirect_to edit_user_setting_path(current_user.user_setting)
#          redirect_to @pack_list
        }
        format.json { render :show, status: :created, location: @pack_list }
      else
        format.html { render :new }
        format.json { render json: @pack_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT v2/pack_lists/1
  # PATCH/PUT v2/pack_lists/1.json
  def update
    @pack_list = PackList.update(current_user.token, current_yard_id, pack_list_params)
    respond_to do |format|
      format.html {
        if @pack_list == 'true'
          flash[:success] = 'PackList was successfully updated.'
        else
          flash[:danger] = 'Error updating PackList.'
        end
        redirect_to pack_contract_path(pack_list_params[:contract_id], contract_number: pack_list_params[:contract_number])
      }
    end
  end

  # DELETE v2/pack_lists/1
  # DELETE v2/pack_lists/1.json
  def destroy
    @pack_list.destroy
    respond_to do |format|
      format.html { redirect_to pack_lists_url, notice: 'PackList was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def pack_fields
    respond_to do |format|
      format.js
    end
  end
  
  def add_pack
    respond_to do |format|
      format.html {
        @add_pack_response = PackList.add_pack(current_user.token, current_yard_id, params[:id], params[:pack_id])
        if @add_pack_response["Success"] == 'true'
          if @add_pack_response["AvailableContractItems"]["ContractItemInformation"].blank?
            flash[:success] = 'Pack added to pack list successfully.'
            redirect_to pack_shipment_path(params[:pack_shipment_id])
          else
            flash[:danger] = 'More than one contract item.'
            redirect_to pack_shipment_path(params[:pack_shipment_id])
          end
        else
          flash[:danger] = @add_pack_response["FailureInformation"]
          redirect_to pack_shipment_path(params[:pack_shipment_id])
        end
      }
      format.json {
        @add_pack_response = PackList.add_pack(current_user.token, current_yard_id, params[:id], params[:pack_id])
#        @add_pack_response = {"Success" => "true"}
        if @add_pack_response["Success"] == 'true'
          if @add_pack_response["AvailableContractItems"]["ContractItemInformation"].blank?
            render json: {}, :status => :ok
          else
            render json: {message: "More than one contract item.", contract_items: @add_pack_response["AvailableContractItems"]["ContractItemInformation"]}, status: :ok
          end
        else
          render json: {error: @add_pack_response["FailureInformation"]}, status: :unprocessable_entity
        end
      }
    end
  end
  
  def remove_pack
    respond_to do |format|
      format.html {
        @remove_pack_response = PackList.remove_pack(current_user.token, current_yard_id, params[:id], params[:pack_id])
        if @remove_pack_response["Success"] == 'true'
          flash[:success] = 'Pack removed from pack list.'
          redirect_to pack_shipment_path(params[:pack_shipment_id])
        else
          flash[:danger] = @remove_pack_response["FailureInformation"]
          redirect_to pack_shipment_path(params[:pack_shipment_id])
        end
      }
      format.json {
        @remove_pack_response = PackList.remove_pack(current_user.token, current_yard_id, params[:id], params[:pack_id])
        if @remove_pack_response["Success"] == 'true'
          render json: {}, :status => :ok
        else
          render json: {error: @remove_pack_response["FailureInformation"]}, status: :unprocessable_entity
        end
      }
    end
  end
  
  def add_pack_to_contract_item
    respond_to do |format|
      format.html {
        @add_pack_to_contract_item_response = PackList.add_pack_to_contract_item(current_user.token, current_yard_id, params[:id], params[:pack_id], params[:contract_item_id])
        if @add_pack_to_contract_item_response["Success"] == 'true'
          flash[:success] = 'Pack added to contract item successfully.'
          redirect_to pack_shipment_path(params[:pack_shipment_id])
        else
          flash[:danger] = @add_pack_to_contract_item_response["FailureInformation"]
          redirect_to pack_shipment_path(params[:pack_shipment_id])
        end
      }
      format.json {
        @add_pack_to_contract_item_response = PackList.add_pack_to_contract_item(current_user.token, current_yard_id, params[:id], params[:pack_id], params[:contract_item_id])
        if @add_pack_to_contract_item_response["Success"] == 'true'
          render json: {}, :status => :ok
        else
          render json: {error: @add_pack_to_contract_item_response["FailureInformation"]}, status: :unprocessable_entity
        end
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pack_list
      @pack_list = PackList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pack_list_params
      params.require(:pack_list).permit(:id, :description, :quantity, :net, :contract_number, :contract_id, packs: [:id, :description, :gross, :tare, :net, :quantity])
    end
end
