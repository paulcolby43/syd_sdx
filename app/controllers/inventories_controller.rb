class InventoriesController < ApplicationController
  before_filter :login_required
  before_action :set_inventory, only: [:show, :edit, :update, :destroy, :add_scanned_pack]

  # GET /inventories
  # GET /inventories.json
  def index
    authorize! :index, :inventories
    @inventories = current_user.company.inventories.sort_by(&:created_at).reverse
  end

  # GET /inventories/1
  # GET /inventories/1.json
  def show
    authorize! :show, :inventories
    @remaining_packs = @inventory.closed_packs - @inventory.scanned_packs
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
        format.html { 
          if @inventory.update(inventory_params)
            flash[:success] = 'Inventory was successfully updated.'
            redirect_to @inventory
          else
            flash[:danger] = 'Error updating inventory.'
            redirect_to @inventory
          end
          }
  #        format.html { redirect_to @user_setting, notice: 'User setting was successfully updated.' }
        format.json { 
          @inventory.update_attribute(:title, params[:value])
          render json: {}, status: :ok
        }
    end
  end
  
  def add_scanned_pack
    respond_to do |format|
      format.html { 
        flash[:success] = 'Inventory was successfully updated.'
        redirect_to @inventory
        }
      format.json { 
#        pack = Pack.find_by_id(current_user.token, current_yard_id, 0, params[:pack_id])
        search = Pack.search_by_tag(current_user.token, current_yard_id, params[:tag_number])
        unless search.blank?
          pack = search.first 
          pack.delete("xmlns:d2p1") # Remove first hash element so can make a clean comparison with closed packs list
        end
        unless pack.blank?
          if @inventory.scanned_packs.include?(pack)
            # Pack is already in scanned pack array
            render json: {message: "Pack already scanned"}, status: :ok
          else
            @inventory.scanned_packs << pack 
            @inventory.save
            if @inventory.closed_packs.include?(pack)
              render json: {}, status: :ok 
            else
              render json: {message: "Pack is not in closed pack list"}, status: :ok
            end
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
