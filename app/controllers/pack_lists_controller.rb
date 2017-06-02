class PackListsController < ApplicationController
  before_filter :login_required  

  # GET /pack_lists
  # GET /pack_lists.json
  def index
    authorize! :index, :pack_lists
#    @pack_lists = current_user.pack_lists
#    @pack_lists = Yard.pack_lists(current_yard_id)
     @status = "#{params[:status].blank? ? '0' : params[:status]}"
#     @pack_lists = Kaminari.paginate_array(PackList.test_array).page(params[:page]).per(10)
    @pack_lists = Kaminari.paginate_array(PackList.all(current_user.token, current_yard_id, @status)).page(params[:page]).per(10)
  end

  # GET /pack_lists/1
  # GET /pack_lists/1.json
  def show
    authorize! :show, :pack_lists
    @contract_id = params[:contract_id]
    @pack_list = PackList.find_by_id(current_user.token, current_yard_id, @contract_id, params[:id])
#    @pack_list = {"Customer"=>nil, "CustomerId"=>{"i:nil"=>"true"}, "DateClosed"=>"2015-12-08T18:56:03.177", "DateCreated"=>"2015-12-08T18:56:03", "Id"=>"07043fd5-525e-4568-b54a-0c3d17c5ca99", "InternalPackListNumber"=>"OY624", "InventoryCode"=>"SSteel", "Location"=>nil, "NetWeight"=>"200.0000", "PrintDescription"=>"304 Stainless", "Quantity"=>"0.00", "Row"=>nil, "TagNumber"=>"624", "UnitOfMeasure"=>"LB", "VoidDate"=>{"i:nil"=>"true"}, "Yard"=>"Main Yard"}
    respond_to do |format|
      format.html {}
      format.json {render json: {"name" => @pack_list['PrintDescription']} } 
    end
  end

  # GET /pack_lists/new
  def new
  end

  # GET /pack_lists/1/edit
  def edit
    authorize! :edit, :pack_lists
    @status = "#{params[:status].blank? ? '0' : params[:status]}"
    @pack_list = PackList.find_by_id(current_user.token, current_yard_id, @status, params[:id])
  end

  # POST /pack_lists
  # POST /pack_lists.json
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

  # PATCH/PUT /pack_lists/1
  # PATCH/PUT /pack_lists/1.json
  def update
    @pack_list = PackList.update(current_user.token, current_yard_id, pack_list_params)
    respond_to do |format|
      format.html {
        if @pack_list == 'true'
          flash[:success] = 'PackList was successfully updated.'
        else
          flash[:danger] = 'Error updating PackList.'
        end
        redirect_to pack_lists_path
      }
    end
  end

  # DELETE /pack_lists/1
  # DELETE /pack_lists/1.json
  def destroy
    @pack_list.destroy
    respond_to do |format|
      format.html { redirect_to pack_lists_url, notice: 'PackList was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pack_list
      @pack_list = PackList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pack_list_params
      params.require(:pack_list).permit(:id, :description, :quantity, :net)
    end
end
