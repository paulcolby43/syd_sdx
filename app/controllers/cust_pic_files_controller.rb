class CustPicFilesController < ApplicationController
  before_filter :login_required
  before_action :set_cust_pic_file, only: [:show, :edit, :update, :destroy]
#  load_and_authorize_resource

  # GET /cust_pic_files
  # GET /cust_pic_files.json
  def index
#    @cust_pic_files = CustPicFile.all
    @cust_pic_files = current_user.cust_pic_files
  end

  # GET /cust_pic_files/1
  # GET /cust_pic_files/1.json
  def show
  end

  # GET /cust_pic_files/new
  def new
    @cust_pic_file = CustPicFile.new
  end

  # GET /cust_pic_files/1/edit
  def edit
  end

  # POST /cust_pic_files
  # POST /cust_pic_files.json
  def create
    respond_to do |format|
      format.html { 
        @cust_pic_file = CustPicFile.new(cust_pic_file_params)
        if @cust_pic_file.save
          redirect_to :back, notice: 'CustPic file was successfully created.' 
        else
          render :new
        end
        }
      format.json { 
        @cust_pic_file = CustPicFile.new(cust_pic_file_params)
        if @cust_pic_file.save
          render :show, status: :created, location: @cust_pic_file 
        else
          render json: @cust_pic_file.errors, status: :unprocessable_entity
        end
        }
      format.js {
#        @cust_pic_file = CustPicFile.create(user_id: 1, customer_number: "77", location: "404168351", event_code: "Photo ID", remote_file_url: "http://qb.scrapyarddog.com/tud_devices/show_scanned_jpeg_image")
        @cust_pic_file = CustPicFile.create(cust_pic_file_params)
      }
    end
  end

  # PATCH/PUT /cust_pic_files/1
  # PATCH/PUT /cust_pic_files/1.json
  def update
    respond_to do |format|
      if @cust_pic_file.update(cust_pic_file_params)
        format.html { redirect_to @cust_pic_file, notice: 'CustPic file was successfully updated.' }
        format.json { render :show, status: :ok, location: @cust_pic_file }
      else
        format.html { render :edit }
        format.json { render json: @cust_pic_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cust_pic_files/1
  # DELETE /cust_pic_files/1.json
  def destroy
    @cust_pic_file.destroy
    respond_to do |format|
      format.html { redirect_to cust_pic_files_url, notice: 'CustPic file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cust_pic_file
      @cust_pic_file = CustPicFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cust_pic_file_params
      # order matters here in that to have access to model attributes in uploader methods, they need to show up before the file param in this permitted_params list 
      params.require(:cust_pic_file).permit(:name, :file, :remote_file_url, :user_id, :vendor_id, :customer_number, :location, :event_code, :cust_pic_id, 
        :hidden, :blob_id, :vin_number, :tag_number, :yard_id)
    end
end
