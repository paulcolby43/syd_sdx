class CompaniesController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource
  before_action :set_company, only: [:show, :edit, :update]

  # GET /companies
  # GET /companies.json
  def index
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
  end

  # GET /companies/new
  def new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
#        format.html { redirect_to images_path, notice: 'Company was successfully created.' }
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { 
          flash[:success] = 'Company was successfully updated.'
#          redirect_to root_path
          redirect_to edit_user_setting_path(current_user.user_setting)
          }
#        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { render :show, status: :ok, location: @company }
#        format.js { render js: "alert('Company was successfully updated.')" }
      else
        format.html { 
          flash.now[:danger] = 'Error updating company.'
          render :edit 
          }
        format.json { render json: @company.errors, status: :unprocessable_entity }
#        format.js { render js: "alert('Company update failed.')" }
      end
    end
  end
  
  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name, :dragon_api, :leads_online_store_id, :leads_online_ftp_username, :leads_online_ftp_password,
      :custom_field_1, :custom_field_2, :custom_field_1_value, :custom_field_2_value, :address1, :address2, :city, :state, :zip, :phone, 
      :logo, :logo_cache, :remove_logo, :jpegger_service_ip, :jpegger_service_port, :include_shipments, :include_inventories, :include_external_users)
    end
end
