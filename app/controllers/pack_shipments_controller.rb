class PackShipmentsController < ApplicationController
  before_filter :login_required  

  # GET /pack_shipments
  # GET /pack_shipments.json
  def index
    authorize! :index, :pack_shipments
#    @query_string = params[:q].blank? ? '' : "%#{params[:q]}%"
    @pack_shipments = Kaminari.paginate_array(PackShipment.all(current_user.token, current_yard_id)).page(params[:page]).per(100)
  end

  # GET /pack_shipments/1
  # GET /pack_shipments/1.json
  def show
    authorize! :show, :pack_shipments
    @pack_shipment = PackShipment.find(current_user.token, current_yard_id, params[:id])
    @pack_list = PackShipment.pack_list(current_user.token, current_yard_id, params[:id], @pack_shipment['ContractHeadId'])
    @contract_items = PackShipment.contract_items(current_user.token, current_yard_id, params[:id], @pack_shipment['ContractHeadId'])
    @current_packs = PackList.pack_items(current_user.token, current_yard_id, @pack_list['Id'])
    @available_packs_array = Pack.all(current_user.token, current_yard_id, 0).collect{ |pack| [ pack['TagNumber'], pack['Id'] ] }
#    unless params[:pack_tag_number].blank?
#      @available_packs = Pack.find_all_by_tag_number(current_user.token, current_yard_id, 0, params[:pack_tag_number])
#    end
#    @pack_list = PackList.all(current_user.token, current_yard_id, @pack_shipment['Id'])
    respond_to do |format|
      format.html {}
      format.json {render json: {"name" => @pack_shipment['ShipmentNumber']} } 
      format.js
    end
  end

  # GET /pack_shipments/new
  def new
  end

  # GET /pack_shipments/1/edit
  def edit
    authorize! :edit, :pack_shipments
    @status = "#{params[:status].blank? ? '0' : params[:status]}"
    @pack_shipment = PackShipment.find_by_id(current_user.token, current_yard_id, @status, params[:id])
  end

  # POST /pack_shipments
  # POST /pack_shipments.json
  def create
    @pack_shipment = PackShipment.new(pack_shipment_params)

    respond_to do |format|
      if @pack_shipment.save
        format.html { 
          flash[:success] = 'PackShipment was successfully created.'
          redirect_to edit_user_setting_path(current_user.user_setting)
#          redirect_to @pack_shipment
        }
        format.json { render :show, status: :created, location: @pack_shipment }
      else
        format.html { render :new }
        format.json { render json: @pack_shipment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pack_shipments/1
  # PATCH/PUT /pack_shipments/1.json
  def update
    @pack_shipment = PackShipment.update(current_user.token, current_yard_id, pack_shipment_params)
    respond_to do |format|
      format.html {
        if @pack_shipment == 'true'
          flash[:success] = 'PackShipment was successfully updated.'
        else
          flash[:danger] = 'Error updating PackShipment.'
        end
        redirect_to pack_shipments_path
      }
    end
  end

  # DELETE /pack_shipments/1
  # DELETE /pack_shipments/1.json
  def destroy
    @pack_shipment.destroy
    respond_to do |format|
      format.html { redirect_to pack_shipments_url, notice: 'PackShipment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pack_shipment
      @pack_shipment = PackShipment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pack_shipment_params
      params.require(:pack_shipment).permit(:id, :description, :quantity, :net)
    end
end
