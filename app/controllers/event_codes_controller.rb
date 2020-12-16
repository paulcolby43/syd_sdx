class EventCodesController < InheritedResources::Base
  before_filter :login_required
  load_and_authorize_resource
  before_action :set_event_code, only: [:show, :edit, :update, :destroy]
  
  # GET /event_codes
  # GET /event_codes.json
  def index
#    @event_codes = EventCode.all
#    @event_codes = current_user.company.event_codes.order(:name)
    @event_codes = current_user.company.event_codes
  end

  # GET /event_codes/1
  # GET /event_codes/1.json
  def show
  end

  # GET /event_codes/new
  def new
    @event_code = EventCode.new
  end

  # GET /event_codes/1/edit
  def edit
  end

  # POST /event_codes
  # POST /event_codes.json
  def create
    @event_code = EventCode.new(event_code_params)

    respond_to do |format|
      if @event_code.save
        format.html { 
          flash[:success] = 'Event code was successfully created.'
#          redirect_to @event_code
          redirect_to edit_user_setting_path(current_user.user_setting)
          }
        format.json { render :show, status: :created, location: @event_code }
      else
        format.html { 
          flash.now[:danger] = 'Error creating Event Code.'
          render :new 
          }
        format.json { render json: @event_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /event_codes/1
  # PATCH/PUT /event_codes/1.json
  def update
    respond_to do |format|
      if @event_code.update(event_code_params)
        format.html { 
          flash[:success] = 'Event code was successfully updated.'
          redirect_to @event_code
        }
        format.json { render :show, status: :ok, location: @event_code }
      else
        format.html { 
          flash.now[:danger] = 'Error updating Event.'
          render :edit 
          }
        format.json { render json: @event_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_codes/1
  # DELETE /event_codes/1.json
  def destroy
    @event_code.destroy
    respond_to do |format|
      format.html { redirect_to event_codes_url, notice: 'Event code was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  # PATCH /event_codes/sort
  def sort
    params[:event_code].each.with_index(1) do |id, index|
      EventCode.where(id: id).update_all(position: index)
    end
    
    head :ok
  end

  private
  
    def set_event_code
      @event_code = EventCode.find(params[:id])
    end

    def event_code_params
      params.require(:event_code).permit(:name, :camera_class, :camera_position, :user_id, :company_id, :include_in_fetch_lists, :include_in_shipments, :include_in_images)
    end
end

