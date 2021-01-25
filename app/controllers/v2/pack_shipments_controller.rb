class PackShipmentsController < ApplicationController
  before_filter :login_required  
  
#  include ActionController::Live # required for streaming download
  include ActionController::Streaming
  include Zipline

  # GET /pack_shipments
  # GET /pack_shipments.json
  def index
    authorize! :index, :pack_shipments
#    @query_string = params[:q].blank? ? '' : "%#{params[:q]}%"
    @status = "#{params[:status].blank? ? 'held' : params[:status]}"
    @q = params[:q]
    if @status == 'held'
      pack_shipments = PackShipment.all_held(current_user.token, current_yard_id)
    elsif @status == 'closed'
      pack_shipments = PackShipment.all_closed(current_user.token, current_yard_id)
    end
    unless @q.blank?
      pack_shipments = PackShipment.shipments_search(pack_shipments, @q)
    end
    @pack_shipments = Kaminari.paginate_array(pack_shipments).page(params[:page]).per(10)
  end

  # GET /pack_shipments/1
  # GET /pack_shipments/1.json
  def show
    authorize! :show, :pack_shipments
    @pack_shipment = PackShipment.find(current_user.token, current_yard_id, params[:id])
    @pack_list = PackShipment.pack_list(current_user.token, current_yard_id, params[:id], @pack_shipment['ContractHeadId'])
#    PackList.set_shipment_id(current_user.token, current_yard_id, @pack_list['Id'], params[:id], @pack_shipment['ContractHeadId']) # Set the shipment_id of pack_list so they're connected correctly
    @contract_items = PackShipment.contract_items(current_user.token, current_yard_id, params[:id], @pack_shipment['ContractHeadId'])
    @current_packs = PackList.pack_items(current_user.token, current_yard_id, @pack_list['Id'])
    @available_packs_array = Pack.all(current_user.token, current_yard_id, 0).collect{ |pack| [ pack['TagNumber'], pack['Id'] ] }
#    @shipment_images = Shipment.where(ticket_nbr: @pack_shipment["ShipmentNumber"], yardid: current_yard_id)
#    @images_array = Shipment.api_find_all_by_shipment_number(@pack_shipment["ShipmentNumber"], current_user.company).reverse # Shipment images
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
    @pack_shipment = PackShipment.find(current_user.token, current_yard_id, params[:id])
    @pack_list = PackShipment.pack_list(current_user.token, current_yard_id, params[:id], @pack_shipment['ContractHeadId'])
#    PackList.set_shipment_id(current_user.token, current_yard_id, @pack_list['Id'], params[:id], @pack_shipment['ContractHeadId']) # Set the shipment_id of pack_list so they're connected correctly
    @contract_items = PackShipment.contract_items(current_user.token, current_yard_id, params[:id], @pack_shipment['ContractHeadId'])
    @current_packs = PackList.pack_items(current_user.token, current_yard_id, @pack_list['Id'])
    @available_packs_array = Pack.all(current_user.token, current_yard_id, 0).collect{ |pack| [ pack['TagNumber'], pack['Id'] ] }
    @status = "#{params[:status].blank? ? 'held' : params[:status]}"
    if @pack_shipment['ShipmentStatus'] == '1'
      @status = 'held'
    elsif @pack_shipment['ShipmentStatus'] == '0'
      @status = 'closed'
    end
    respond_to do |format|
      format.html {
        if @pack_shipment['ShipmentType'] == '0'
          flash[:danger] = 'No actions necessary for a Loose Shipment.'
          redirect_to :back
        end
      }
      format.json {render json: {"name" => @pack_shipment['ShipmentNumber']} } 
      format.js
    end
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
  
  # GET /pack_shipments/1/fetches
  # GET /pack_shipments/1/fetches.json
  def fetches
    authorize! :fetches, :pack_shipments
    @pack_shipment = PackShipment.find(current_user.token, current_yard_id, params[:id])
    @images_array = Shipment.api_find_all_by_shipment_number(@pack_shipment["ShipmentNumber"], current_user.company, current_yard_id).reverse # Shipment images
    @fetch_event_codes = current_user.company.fetch_event_codes
    respond_to do |format|
      format.html {}
    end
  end
  
  # GET /pack_shipments/1/show_pictures
  # GET /pack_shipments/1/show_pictures.json
  def show_pictures
    authorize! :pictures, :pack_shipments
    @pack_shipment = PackShipment.find(current_user.token, current_yard_id, params[:id])
    @pack_list = PackShipment.pack_list(current_user.token, current_yard_id, params[:id], @pack_shipment['ContractHeadId'])
    @current_packs = PackList.pack_items(current_user.token, current_yard_id, @pack_list['Id'])
    if current_user.customer? and not current_user.customer_guid.blank?
      @images_array = Shipment.api_find_all_by_shipment_number(@pack_shipment["ShipmentNumber"], current_user.company, @pack_shipment["YardId"]).reverse # Shipment images
    else
      @images_array = Shipment.api_find_all_by_shipment_number(@pack_shipment["ShipmentNumber"], current_user.company, current_yard_id).reverse # Shipment images
    end
    @inventory_tags_array = []
    @current_packs.each do |pack|
      @inventory_tags_array << InvTag.api_find_all_by_ticket_number(pack['PackInfo']['TagNumber'], current_user.company, current_yard_id) 
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