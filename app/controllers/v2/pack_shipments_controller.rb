class V2::PackShipmentsController < ApplicationController
  before_filter :login_required  
  
#  include ActionController::Live # required for streaming download
  include ActionController::Streaming
  include Zipline

  # GET v2/pack_shipments
  # GET v2/pack_shipments.json
  def index
    authorize! :index, :pack_shipments
    @status = "#{params[:status].blank? ? 'HELD' : params[:status]}"
    @q = params[:q]
    unless params[:q].blank?
      filter = ' {"shipmentStatus": {"eq": "' +  @status + '"}, "or": [{"shipmentNumber": {"eq": ' +  "#{@q.to_i}" + '}}, {"bookingNumber": {"eq": "' +  @q + '" }}, {"containerNumber": {"eq": "' +  @q + '" }} ]} '
    else
      filter = ' {"shipmentStatus": {"eq": "' +  @status + '"}} '
    end
    pack_shipments = PackShipment.v2_all_by_filter(filter)
    @pack_shipments = Kaminari.paginate_array(pack_shipments).page(params[:page]).per(10)
  end

  # GET /pack_shipments/1
  # GET /pack_shipments/1.json
  def show
    authorize! :show, :pack_shipments
    @pack_shipment = PackShipment.v2_find_by_id(params[:id])
    @work_order = @pack_shipment.related_work_order
    @customer = @related_work_order.customer unless @work_order.blank?
    @pack_list = @pack_shipment.pack_list_head
    @contract = @pack_shipment.contract_head
    @contract_items = @contract.contract_items unless @contract.blank?
    @pack_list_items = @pack_list.pack_list_items unless @pack_list.blank?
    @available_packs_array = Pack.all(current_user.token, current_yard_id, 0).collect{ |pack| [ pack['TagNumber'], pack['Id'] ] }
    respond_to do |format|
      format.html {}
      format.json {render json: {"name" => @pack_shipment.shipment_number} } 
      format.js
    end
  end

  # GET v2/pack_shipments/new
  def new
  end

  # GET v2/pack_shipments/1/edit
  def edit
    authorize! :edit, :pack_shipments
    @pack_shipment = PackShipment.v2_find_by_id(params[:id])
    @work_order = @pack_shipment.related_work_order
    @customer = @related_work_order.customer unless @work_order.blank?
    @pack_list = @pack_shipment.pack_list_head
    @contract = @pack_shipment.contract_head
    @contract_items = @contract.contract_items unless @contract.blank?
    @pack_list_items = @pack_list.pack_list_items unless @pack_list.blank?
    @available_packs_array = Pack.all(current_user.token, current_yard_id, 0).collect{ |pack| [ pack['TagNumber'], pack['Id'] ] }
    @status = @pack_shipment_shipment_status
    respond_to do |format|
      format.html {
        if @pack_shipment_shipment_type == 'LOOSE'
          flash[:danger] = 'No actions necessary for a Loose Shipment.'
          redirect_to :back
        end
      }
      format.json {render json: {"name" => @pack_shipment.shipment_number} } 
      format.js
    end
  end

  # POST v2/pack_shipments
  # POST v2/pack_shipments.json
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

  # PATCH/PUT v2/pack_shipments/1
  # PATCH/PUT v2/pack_shipments/1.json
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

  # DELETE v2/pack_shipments/1
  # DELETE v2/pack_shipments/1.json
  def destroy
    @pack_shipment.destroy
    respond_to do |format|
      format.html { redirect_to pack_shipments_url, notice: 'PackShipment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  # GET /pack_shipments/1/fetches
  # GET /pack_shipments/1/fetches.json
  def fetches
    authorize! :fetches, :pack_shipments
    @pack_shipment = PackShipment.v2_find_by_id(params[:id])
    @work_order = @pack_shipment.related_work_order
    @customer = @related_work_order.customer unless @work_order.blank?
    @images_array = Shipment.api_find_all_by_shipment_number(@pack_shipment.shipment_number, current_user.company, current_yard_id).reverse # Shipment images
    @fetch_event_codes = current_user.company.fetch_event_codes
    respond_to do |format|
      format.html {}
    end
  end
  
  # GET v2/pack_shipments/1/show_pictures
  # GET v2/pack_shipments/1/show_pictures.json
  def show_pictures
    authorize! :pictures, :pack_shipments
    @pack_shipment = PackShipment.v2_find_by_id(params[:id])
    @work_order = @pack_shipment.related_work_order
    @customer = @related_work_order.customer unless @work_order.blank?
    @contract = @pack_shipment.contract_head
    @pack_list = @pack_shipment.pack_list_head
    @pack_list_items = @pack_list.pack_list_items unless @pack_list.blank?
    
    @images_array = Shipment.api_find_all_by_shipment_number(@pack_shipment.shipment_number, current_user.company, @pack_shipment.yard_id).reverse # Shipment images
    @inventory_tags_array = []
    unless @pack_list_items.blank?
      @pack_list_items.each do |pack_list_item|
        @inventory_tags_array << InvTag.api_find_all_by_ticket_number(pack_list_item.pack.tag_number, current_user.company, current_yard_id) 
      end
    end
    @inventory_tags_array = @inventory_tags_array.flatten # Need to flatten array since may end up with array filled with arrays, and we only want a one dimensional array
    respond_to do |format|
      format.html {}
      format.json {render json: {"name" => @pack_shipment['ShipmentNumber']} } 
      format.js
    end
  end
  
  def images_zip
    @pack_shipment = PackShipment.find(current_user.token, current_yard_id, params[:id])
    if current_user.customer? and not current_user.customer_guid.blank?
      @images_array = Shipment.api_find_all_by_shipment_number(@pack_shipment["ShipmentNumber"], current_user.company, @pack_shipment["YardId"]).reverse # Shipment images
    else
      @images_array = Shipment.api_find_all_by_shipment_number(@pack_shipment["ShipmentNumber"], current_user.company, current_yard_id).reverse # Shipment images
    end
    
    require 'open-uri'
    files = @images_array.map.with_index{ |image,index| [Shipment.jpeg_image_url(current_user.company, image['CAPTURE_SEQ_NBR'], current_yard_id), "shipment_#{image['TICKET_NBR']}_booking_#{image['BOOKING_NBR']}_container_#{image['CONTAINER_NBR']}_#{image['EVENT_CODE']}_#{image['CAPTURE_SEQ_NBR']}.jpg"]}
    name = "shipment_#{@pack_shipment['Id']}"
    file_mappings = files
    .lazy  # Lazy allows us to begin sending the download immediately instead of waiting to download everything
    .map { |url, path| [open(url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}), path] }
    zipline(file_mappings, "#{name}.zip")
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
