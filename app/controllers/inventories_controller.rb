class InventoriesController < ApplicationController
  before_filter :login_required
  before_action :set_inventory, only: [:show, :edit, :update, :destroy, :add_scanned_pack]

  # GET /inventories
  # GET /inventories.json
  def index
    authorize! :index, :inventories
    @inventories = current_user.company.inventories
  end

  # GET /inventories/1
  # GET /inventories/1.json
  def show
    authorize! :show, :inventories
  end

  # GET /inventories/new
  def new
    authorize! :create, :inventories
    @inventory = Inventory.new
#    @closed_packs = Pack.all(current_user.token, current_yard_id, 0)
#    @inventory.closed_packs = Pack.all(current_user.token, current_yard_id, 0)
  end

  # GET /inventories/1/edit
  def edit
    authorize! :edit, :inventories
  end

  # POST /inventories
  # POST /inventories.json
  def create
    @inventory = Inventory.new(inventory_params)
    @closed_packs = Pack.all(current_user.token, current_yard_id, 0)
    @inventory.closed_packs = @closed_packs
    @inventory.scanned_packs = []
    @inventory.user_id = current_user.id
    respond_to do |format|
      if @inventory.save
#        format.html { redirect_to inventories_path, notice: 'Inventory was successfully created.' }
        format.html { 
          flash[:success] = 'Inventory was successfully created.'
          redirect_to @inventory 
          }
        format.json { render :show, status: :created, location: @inventory }
      else
        format.html { 
          flash[:danger] = 'Error creating inventory.'
          redirect_to inventories_path
#          render :new 
          }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inventories/1
  # PATCH/PUT /inventories/1.json
  def update
    respond_to do |format|
      if @inventory.update(inventory_params)
        format.html { 
          flash[:success] = 'Inventory was successfully updated.'
          redirect_to @inventory
          }
  #        format.html { redirect_to @user_setting, notice: 'User setting was successfully updated.' }
        format.json { render :show, status: :ok, location: @inventory }
  #        format.js { render js: "alert('User setting was successfully updated.')" }
      else
        format.html { 
          flash[:danger] = 'Error updating inventory.'
          redirect_to @inventory
          }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
  #        format.js { render js: "alert('User setting update failed.')" }
      end
    end
  end
  
  def add_scanned_pack
    respond_to do |format|
      format.html { 
        flash[:success] = 'Inventory was successfully updated.'
        redirect_to @inventory
        }
      format.json { 
        pack = Pack.find_by_id(current_user.token, current_yard_id, 0, params[:pack_id])
        unless pack.blank?
          unless @inventory.scanned_packs.include?(pack)
            @inventory.scanned_packs << pack 
            @inventory.save
            render json: {}, status: :ok 
#            render json: @inventory, status: :ok
          else
            render json: {message: "Pack already scanned"}, status: :ok
          end
        else
          render json: {error: 'No pack found'}, status: :unprocessable_entity
        end
        }
    end
  end

  # DELETE /inventories/1
  # DELETE /inventories/1.json
  def destroy
    @inventory.destroy
    respond_to do |format|
      format.html { redirect_to inventories_url, notice: 'Inventory was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory
      @inventory = Inventory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inventory_params
#      params.require(:inventory).permit(:id, :user_id, :pack_id, {:scanned_packs => []}, {:closed_packs => []})
      params.permit(:id, :user_id, :pack_id, {:scanned_packs => []}, {:closed_packs => []})
    end
end
