class CommoditiesController < ApplicationController
  before_filter :login_required
#  before_action :set_commodity, only: [:show, :edit, :update, :destroy]

  # GET /commodities
  # GET /commodities.json
  def index
    authorize! :index, :commodities
#    @status = "#{params[:status].blank? ? 'enabled' : params[:status]}"
    @commodity_types = Commodity.types(current_user.token, current_yard_id)
    unless params[:q].blank?
      results = Commodity.search(current_user.token, current_yard_id, params[:q])
#      results = Commodity.search_disabled(current_user.token, current_yard_id, params[:q]) if @status == 'disabled'
#      if results.class == 'Hash'
#        single_commodity_hash = results
#        results = []
#        results << single_commodity_hash
#      end
    else
      results = Commodity.all(current_user.token, current_yard_id)
#      results = Commodity.all_disabled(current_user.token, current_yard_id) if @status == 'disabled'
    end
    respond_to do |format|
      format.html {
        unless results.blank?
          @commodities = Kaminari.paginate_array(results).page(params[:page]).per(25)
        else
          @commodities = []
        end
      }
      format.js {
        unless results.blank?
          @commodities = Kaminari.paginate_array(results).page(params[:page]).per(25)
        else
          @commodities = []
        end
      }
      format.json {
        unless results.blank?
          @commodities = results.collect{ |commodity| {id: commodity['Id'], text: "#{commodity['PrintDescription']} (#{commodity['Code']})"} }
        else
          @commodities = nil
        end
        Rails.logger.info "results: {#{@commodities}}"
        render json: {results: @commodities}
      }
    end
  end
  
  # GET /commodities/customer_index
  # GET /commodities/customer_index.json
  def customer_index
    authorize! :customer_index, :commodities
    @commodity_types = Commodity.types(current_user.token, current_yard_id)
    unless params[:q].blank?
      results = Commodity.search(current_user.token, current_yard_id, params[:q])
    else
      results = Commodity.all(current_user.token, current_yard_id)
    end
    unless results.blank?
      @commodities = Kaminari.paginate_array(results).page(params[:page]).per(25)
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
  
  # GET /commodities/1/customer_show
  # GET /commodities/1/customer_show.json
  def customer_show
    authorize! :customer_show, :commodities
    @commodity = Commodity.find_by_id(current_user.token, current_yard_id, params[:id])
    @commodity_types = Commodity.types(current_user.token, current_yard_id)
    @customer_price = Commodity.price_by_customer(current_user.token, params[:id], current_user.customer_guid)
    respond_to do |format|
      format.html {}
      format.json {render json: {"name" => @commodity['PrintDescription'], "price" => @customer_price} } 
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
#    @price = Commodity.price(current_user.token, params[:id])
#    @customer_price = Commodity.price_by_customer(current_user.token, params[:id], "6b5c0f91-e9db-430d-b9d3-5937a15bcdea")
#    @customer_taxes = Commodity.taxes_by_customer(current_user.token, params[:id], "6b5c0f91-e9db-430d-b9d3-5937a15bcdea")
#    @customer_price = Commodity.price_by_customer(current_user.token, params[:id], "45aa5872-77f1-48fe-8688-22ed04aa1100")
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
  
  # GET /commodities/1/price
  # GET /commodities/1/price.json
  def price
    authorize! :show, :commodities
    @commodity = Commodity.find_by_id(current_user.token, current_yard_id, params[:id])
    price = Commodity.price_by_customer(current_user.token, params[:id], params[:customer_id]) unless params[:customer_id].blank?
    taxes_by_customer = Commodity.taxes_by_customer(current_user.token, params[:id], params[:customer_id]) unless params[:customer_id].blank?
#    tax_percent = taxes_by_customer.first['TaxPercent'] unless taxes_by_customer.blank?
    tax_percent_1 = taxes_by_customer.first['TaxPercent'] unless taxes_by_customer.blank?
    tax_percent_2 = taxes_by_customer.second['TaxPercent'] if not taxes_by_customer.blank? and taxes_by_customer.count > 1
    tax_percent_3 = taxes_by_customer.third['TaxPercent'] if not taxes_by_customer.blank? and taxes_by_customer.count > 2
    Rails.logger.debug "Commodity price and taxes response: #{taxes_by_customer}"
    respond_to do |format|
      format.html {}
      format.json {render json: {"name" => @commodity['PrintDescription'], "price" => "#{price.blank? ? @commodity['ScalePrice'] : price}", 
          "tax_percent_1" =>  tax_percent_1.blank? ? 0 : tax_percent_1.to_f/100, "tax_percent_2" =>  tax_percent_2.blank? ? 0 : tax_percent_2.to_f/100, 
          "tax_percent_3" =>  tax_percent_3.blank? ? 0 : tax_percent_3.to_f/100, "unit_of_measure" => @commodity['UnitOfMeasure']}} 
    end
  end
  
  def unit_of_measure_weight_conversion
    authorize! :show, :commodities
    
    commodity = Commodity.find_by_id(current_user.token, current_yard_id, params[:id])
    unit_of_measure_conversion_response = Commodity.unit_of_measure_weight_conversion(current_user.token, commodity['UnitOfMeasure'], params[:net])
#    @new_weight = Commodity.unit_of_measure_weight_conversion(current_user.token, commodity['UnitOfMeasure'], params[:net])
    if unit_of_measure_conversion_response["Success"] == 'true'
      @new_weight = unit_of_measure_conversion_response["ConvertedValue"]
    end
    
    respond_to do |format|
      format.html {}
      format.json {
        if @new_weight
          render json: {"new_weight" => @new_weight}, status: :ok
        else
          render json: {error: unit_of_measure_conversion_response["FailureInformation"]}, :status => :bad_request
        end
        }
    end
  end
  
  def unit_of_measure_lb_conversion
    unit_of_measure_conversion_response = Commodity.unit_of_measure_weight_conversion(current_user.token, params[:unit_of_measure], params[:net])
    if unit_of_measure_conversion_response["Success"] == 'true'
      @new_weight = unit_of_measure_conversion_response["ConvertedValue"]
    end
    
    respond_to do |format|
      format.html {}
      format.json {
        if @new_weight
          render json: {"new_weight" => @new_weight}, status: :ok
        else
          render json: {error: unit_of_measure_conversion_response["FailureInformation"]}, :status => :bad_request
        end
        }
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
