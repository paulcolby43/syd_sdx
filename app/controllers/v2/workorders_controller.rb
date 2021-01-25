class V2::WorkordersController < ApplicationController
  before_filter :login_required
#  before_action :set_workorder, only: [:show, :edit, :update, :destroy]

  # GET /workorders
  # GET /workorders.json
  def index
#    authorize! :index, :workorders
    results = Workorder.all(current_user.token, current_yard_id)
    unless results.blank?
      @workorders = Kaminari.paginate_array(results).page(params[:page]).per(50)
    else
      @workorders = []
    end
  end

  # GET /workorders/1
  # GET /workorders/1.json
  def show
    authorize! :show, :workorders
#    @workorder = Workorder.find_by_id(current_user.token, current_yard_id, params[:id])
#    @workorder = params[:workorder]
    @workorder = Workorder.v2_find_by_id(params[:id])
    @images_array = Image.api_find_all_by_service_request_number(@workorder.work_order_number, current_user.company, current_yard_id)
    respond_to do |format|
      format.html {}
      format.json {render json: {"id" => @workorder.id} } 
    end
  end

  # GET /workorders/new
  def new
    authorize! :create, :workorders
#    @workorder = Workorder.new
    @workorder_types = Workorder.types(current_user.token, current_yard_id)
  end

  # GET /workorders/1/edit
  def edit
    authorize! :edit, :workorders
    @workorder = Workorder.find_by_id(current_user.token, current_yard_id, params[:id])
    @workorder_types = Workorder.types(current_user.token, current_yard_id)
  end

  # POST /workorders
  # POST /workorders.json
  def create
#    @workorder = Workorder.new(workorder_params)
    @workorder = Workorder.create(current_user.token, current_yard_id, workorder_params)
    respond_to do |format|
      format.html {
        if @workorder == 'true'
          flash[:success] = 'Workorder was successfully created.'
        else
          flash[:danger] = 'Error creating workorder.'
        end
        redirect_to workorders_path
      }
    end
  end

  # PATCH/PUT /workorders/1
  # PATCH/PUT /workorders/1.json
  def update
    @workorder = Workorder.update(current_user.token, current_yard_id, workorder_params)
    respond_to do |format|
      format.html {
        if @workorder == 'true'
          flash[:success] = 'Workorder was successfully updated.'
        else
          flash[:danger] = 'Error updating workorder.'
        end
        redirect_to workorders_path
      }
    end
  end
  
  # PATCH/PUT /workorders/1/update_price
  # PATCH/PUT /workorders/1/update_price.json
  def update_price
    workorder_update_price_response =  Workorder.update_price(current_user.token, current_yard_id, params[:id], params[:value])
    respond_to do |format|
      format.json { 
        if workorder_update_price_response == 'true'
          render json: {}, status: :ok 
        else
          render json: { status: 'error', msg: 'Error updating price'}, status: :ok
        end
        }
#        if workorder_update_price_response == 'true'
##          render json: {'success' => :true, 'pk' => params[:id], 'newValue' => params[:value]}, :status => :ok
#          render json: {}, :status => :ok
#        else
#          render json: {error: 'Workorder price was successfully updated.'}, :status => :bad_request
    end
  end

  # DELETE /workorders/1
  # DELETE /workorders/1.json
  def destroy
    @workorder.destroy
    respond_to do |format|
      format.html { redirect_to workorders_url, notice: 'Workorder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workorder
      @workorder = Workorder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def workorder_params
      params.require(:workorder).permit(:id, :name, :code, :menu_text, :description, :unit_of_measure, :scale_price, :yard_name, :type, :parent_id, :is_disabled)
    end
end
