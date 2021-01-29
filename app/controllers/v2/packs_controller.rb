class V2::PacksController < ApplicationController
  before_filter :login_required  
  include ApplicationHelper

  # GET v2/packs
  # GET v2/packs.json
  def index
    authorize! :index, :packs
    @status = "#{params[:status].blank? ? 'CLOSED' : params[:status]}"
    @q = params[:q]
    unless @q.blank?
      filter = ' {"packStatus": {"eq": "' +  @status + '"}, "tagNumber": {"eq": ' +  "#{@q.to_i}" + '}} '
    else
      filter = ' {"packStatus": {"eq": "' +  @status + '"}} '
    end
    search = Pack.v2_all_by_filter(filter)
    respond_to do |format|
      format.html {
#        search = Pack.all(current_user.token, current_yard_id, @status)
        @packs = Kaminari.paginate_array(search).page(params[:page]).per(0)
      }
      format.json {
        if @q.blank?
          search = []
        end
        unless search.blank?
          @packs = search.collect{ |pack| {id: pack.id, text: "#{pack.print_description}"} }
        else
          @packs = []
        end
        Rails.logger.info "results: {#{@packs}}"
        render json: {results: @packs}
      } 
    end
  end

  # GET v2/packs/1
  # GET v2/packs/1.json
  def show
    authorize! :show, :packs
#    @pack = {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2015-12-08T18:56:03.177", "DateCreated"=>"2015-12-08T18:56:03", "Id"=>"07043fd5-525e-4568-b54a-0c3d17c5ca99", "InternalPackNumber"=>"OY624", "InventoryCode"=>"SSteel", "Location"=>nil, "NetWeight"=>"200.0000", "PrintDescription"=>"304 Stainless", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"624", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}
    respond_to do |format|
      format.html {}
      format.json {
        @status = "#{params[:status].blank? ? 'CLOSED' : params[:status]}"
#        @pack = Pack.find_by_id(current_user.token, current_yard_id, @status, params[:id])
        @pack = Pack.v2_find_by_id(params[:id])
        unless @pack.blank?
          render json: {"name" => @pack.print_description, "internal_pack_number" => @pack.internal_pack_number, "tag_number" => @pack.tag_number, "gross" => @pack.gross_weight, "tare" => @pack.tare_weight, "net" => @pack.net_weight} 
        else
          render json: {message: "No pack found"}, status: :ok
#          render json: {error: 'No pack found'}, status: :unprocessable_entity
        end
        } 
      format.js {
        @pack_id = params[:id]
        @pack_tag_number = params[:pack_tag_number]
        @pack_net_weight = params[:pack_net_weight]
        @pack_list_unit_of_measure = params[:pack_list_unit_of_measure]
        @pack_description = params[:pack_description]
        @pack_shipment_id = params[:pack_shipment_id]
        @pack_list_id = params[:pack_list_id]
        }
    end
  end
  
  def show_information
    authorize! :show_information, :packs
    respond_to do |format|
      format.json {
        search = Pack.search_by_tag(current_user.token, current_yard_id, params[:tag_number])
        @pack = search.first unless search.blank?
        unless @pack.blank?
          render json: {"id" => @pack['Id'], "name" => @pack['PrintDescription'], "internal_pack_number" => @pack['InternalPackNumber'], 
            "tag_number" => @pack['TagNumber'], "gross" => @pack['GrossWeight'], "tare" => @pack['TareWeight'], 
            "net" => @pack['NetWeight'], "status" => @pack['Status'], "status_description" => pack_status_description(@pack['Status'])} 
        else
          render json: {message: "No pack found"}, status: :ok
        end
        } 
    end
  end

  # GET v2/packs/new
  def new
  end

  # GET v2/packs/1/edit
  def edit
    authorize! :edit, :packs
    @status = "#{params[:status].blank? ? '0' : params[:status]}"
    @pack = Pack.find_by_id(current_user.token, current_yard_id, @status, params[:id])
  end

  # POST v2/packs
  # POST v2/packs.json
  def create
    @pack = Pack.new(pack_params)

    respond_to do |format|
      if @pack.save
        format.html { 
          flash[:success] = 'Pack was successfully created.'
          redirect_to edit_user_setting_path(current_user.user_setting)
#          redirect_to @pack
        }
        format.json { render :show, status: :created, location: @pack }
      else
        format.html { render :new }
        format.json { render json: @pack.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT v2/packs/1
  # PATCH/PUT v2/packs/1.json
  def update
    @pack = Pack.update(current_user.token, current_yard_id, pack_params)
    respond_to do |format|
      format.html {
        if @pack == 'true'
          flash[:success] = 'Pack List was successfully updated.'
        else
          flash[:danger] = 'Error updating Pack List.'
        end
        redirect_to packs_path
      }
    end
  end

  # DELETE v2/packs/1
  # DELETE v2/packs/1.json
  def destroy
    @pack.destroy
    respond_to do |format|
      format.html { redirect_to packs_url, notice: 'Pack was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def search_by_tag_number
    authorize! :search_by_tag_number, :packs
    respond_to do |format|
      format.json {
        search = Pack.search_by_tag(current_user.token, current_yard_id, params[:q])
        unless search.empty?
#          @packs = search.collect{ |pack| {id: pack['Id'], text: "#{pack['PrintDescription']}"} }
            @packs = search.collect{ |pack| {id: pack['TagNumber'], text: "#{pack['PrintDescription']}"} }
          Rails.logger.info "results: {#{@packs}}"
        else
          @packs = []
        end
        render json: {results: @packs}, :status => :ok
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pack
      @pack = Pack.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pack_params
      params.require(:pack).permit(:id, :description, :quantity, :net)
    end
end
