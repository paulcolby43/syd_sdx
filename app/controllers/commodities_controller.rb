class CommoditiesController < ApplicationController
  before_filter :login_required
#  before_action :set_commodity, only: [:show, :edit, :update, :destroy]

  # GET /commodities
  # GET /commodities.json
  def index
    authorize! :index, :commodities
#    @status = "#{params[:status].blank? ? 'enabled' : params[:status]}"
    unless params[:q].blank?
      results = Commodity.search(current_user.token, current_yard_id, params[:q])
#      results = Commodity.search_disabled(current_user.token, current_yard_id, params[:q]) if @status == 'disabled'
      if results.class == 'Hash'
        single_commodity_hash = results
        results = []
        results << single_commodity_hash
      end
    else
      results = Commodity.all(current_user.token, current_yard_id)
#      results = Commodity.all_disabled(current_user.token, current_yard_id) if @status == 'disabled'
    end
    unless results.blank?
      @commodities = Kaminari.paginate_array(results).page(params[:page]).per(50)
    else
      @commodities = []
    end
  end

  # GET /commodities/1
  # GET /commodities/1.json
  def show
    authorize! :show, :commodities
    @commodity = Commodity.find_by_id(current_user.token, current_yard_id, params[:id])
    @commodity_types = Commodity.types(current_user.token, current_yard_id)
    respond_to do |format|
      format.html {}
      format.json {render json: {"name" => @commodity['PrintDescription'], "price" => @commodity['ScalePrice']} } 
    end
  end

  # GET /commodities/new
  def new
    authorize! :create, :commodities
#    @commodity = Commodity.new
    @commodity_types = Commodity.types(current_user.token, current_yard_id)
  end

  # GET /commodities/1/edit
  def edit
    authorize! :edit, :commodities
    @commodity = Commodity.find_by_id(current_user.token, current_yard_id, params[:id])
    @commodity_types = Commodity.types(current_user.token, current_yard_id)
  end

  # POST /commodities
  # POST /commodities.json
  def create
#    @commodity = Commodity.new(commodity_params)
    @commodity = Commodity.create(current_user.token, current_yard_id, commodity_params)
    respond_to do |format|
      format.html {
        if @commodity == 'true'
          flash[:success] = 'Commodity was successfully created.'
        else
          flash[:danger] = 'Error creating commodity.'
        end
        redirect_to commodities_path
      }
    end
  end

  # PATCH/PUT /commodities/1
  # PATCH/PUT /commodities/1.json
  def update
    @commodity = Commodity.update(current_user.token, current_yard_id, commodity_params)
    respond_to do |format|
      format.html {
        if @commodity == 'true'
          flash[:success] = 'Commodity was successfully updated.'
        else
          flash[:danger] = 'Error updating commodity.'
        end
        redirect_to commodities_path
      }
    end
  end
  
  # PATCH/PUT /commodities/1/update_price
  # PATCH/PUT /commodities/1/update_price.json
  def update_price
    commodity_update_price_response =  Commodity.update_price(current_user.token, current_yard_id, params[:id], params[:value])
    respond_to do |format|
      format.json { 
        if commodity_update_price_response == 'true'
          render json: {}, status: :ok 
        else
          render json: { status: 'error', msg: 'Error updating price'}, status: :ok
        end
        }
#        if commodity_update_price_response == 'true'
##          render json: {'success' => :true, 'pk' => params[:id], 'newValue' => params[:value]}, :status => :ok
#          render json: {}, :status => :ok
#        else
#          render json: {error: 'Commodity price was successfully updated.'}, :status => :bad_request
    end
  end

  # DELETE /commodities/1
  # DELETE /commodities/1.json
  def destroy
    @commodity.destroy
    respond_to do |format|
      format.html { redirect_to commodities_url, notice: 'Commodity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commodity
      @commodity = Commodity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def commodity_params
      params.require(:commodity).permit(:id, :name, :code, :menu_text, :description, :unit_of_measure, :scale_price, :yard_name, :type, :parent_id, :is_disabled)
    end
end
