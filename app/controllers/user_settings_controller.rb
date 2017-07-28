class UserSettingsController < ApplicationController
  before_filter :login_required
#  load_and_authorize_resource
  before_action :set_user_setting, only: [:show, :edit, :update]

  # GET /user_settings
  # GET /user_settings.json
  def index
#    @user_settings = UserSetting.all
    @user_settings = current_user.user_setting
  end

  # GET /user_settings/1
  # GET /user_settings/1.json
  def show
    @contract = Yard.contract(current_yard_id)
    @currencies = Ticket.currencies(current_user.token)
  end

  # GET /user_settings/new
  def new
  end

  # GET /user_settings/1/edit
  def edit
    @contract = Yard.contract(current_yard_id)
    @currencies = Ticket.currencies(current_user.token)
  end

  # POST /user_settings
  # POST /user_settings.json
  def create
    @user_setting = UserSetting.new(user_setting_params)
    @currencies = Ticket.currencies(current_user.token)
    respond_to do |format|
      if @user_setting.save
#        format.html { redirect_to images_path, notice: 'User setting was successfully created.' }
        format.html { redirect_to @user_setting, notice: 'User setting was successfully created.' }
        format.json { render :show, status: :created, location: @user_setting }
      else
        format.html { render :new }
        format.json { render json: @user_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_settings/1
  # PATCH/PUT /user_settings/1.json
  def update
    respond_to do |format|
      @currencies = Ticket.currencies(current_user.token)
      if @user_setting.update(user_setting_params)
        format.html { 
          flash[:success] = 'User setting was successfully updated.'
          redirect_to root_path
          }
#        format.html { redirect_to @user_setting, notice: 'User setting was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_setting }
#        format.js { render js: "alert('User setting was successfully updated.')" }
      else
        format.html { 
          flash.now[:danger] = 'Error updating ticket.'
          render :edit 
          }
        format.json { render json: @user_setting.errors, status: :unprocessable_entity }
#        format.js { render js: "alert('User setting update failed.')" }
      end
    end
  end
  
#  def set_device_group
#    respond_to do |format|
#      if @user_setting.update(user_setting_params)
#        format.html { redirect_to @user_setting, notice: 'User setting was successfully updated.' }
#        format.json { render :show, status: :ok, location: @user_setting }
#      else
#        format.html { render :edit }
#        format.json { render json: @user_setting.errors, status: :unprocessable_entity }
#      end
#    end
#  end

  # DELETE /user_settings/1
  # DELETE /user_settings/1.json
  def destroy
    @user_setting.destroy
    respond_to do |format|
      format.html { redirect_to user_settings_url, notice: 'User setting was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_setting
      @user_setting = UserSetting.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_setting_params
      params.require(:user_setting).permit(:show_thumbnails, :table_name, :show_customer_thumbnails, :show_ticket_thumbnails, :device_group_id, :currency_id)
    end
end
