class SuspectListsController < ApplicationController
  before_filter :login_required
  before_action :set_suspect_list, only: [:show, :edit, :update, :destroy, :images_download, :images_zip]
  
#  include ActionController::Live # required for streaming download
#  include ActionController::Streaming # required for streaming download
#  include ZipTricks::RailsStreaming
#  include Zipline
  

  # GET /suspect_lists
  # GET /suspect_lists.json
  def index
    authorize! :index, :suspect_lists
    @suspect_lists = SuspectList.all
  end

  # GET /suspect_lists/1
  # GET /suspect_lists/1.json
  def show
    authorize! :show, :suspect_lists
    require 'csv'
    unless @suspect_list.file.blank? or @suspect_list.file.path.blank?
      @headers = @suspect_list.csv_file_headers
      csv_table = @suspect_list.csv_file_table
      @number_of_table_rows = csv_table.count unless csv_table.blank?
      @csv_table = Kaminari.paginate_array(csv_table).page(params[:page]).per(20)
    end
  end

  # GET /suspect_lists/new
  def new
    authorize! :create, :suspect_lists
    @suspect_list = SuspectList.new
  end

  # GET /suspect_lists/1/edit
  def edit
    authorize! :edit, :suspect_lists
  end

  # POST /suspect_lists
  # POST /suspect_lists.json
  def create
    @suspect_list = SuspectList.new(suspect_list_params)

    respond_to do |format|
      if @suspect_list.save
        format.html { 
          flash[:success] = 'Suspect list was successfully created.'
          redirect_to @suspect_list
          }
        format.json { render :show, status: :created, location: @suspect_list }
      else
        format.html { render :new }
        format.json { render json: @suspect_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /suspect_lists/1
  # PATCH/PUT /suspect_lists/1.json
  def update
    respond_to do |format|
      if @suspect_list.update(suspect_list_params)
        format.html { 
          flash[:success] = 'Suspect list was successfully updated.'
          redirect_to @suspect_list
          }
        format.json { render :show, status: :ok, location: @suspect_list }
      else
        format.html { render :edit }
        format.json { render json: @suspect_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /suspect_lists/1
  # DELETE /suspect_lists/1.json
  def destroy
    authorize! :edit, :suspect_lists
    @suspect_list.destroy
    respond_to do |format|
      format.html { 
        flash[:success] = 'Suspect list was successfully destroyed.'
        redirect_to suspect_lists_url
        }
      format.json { head :no_content }
    end
  end
  
  # POST /suspect_lists/1/images_download
  def images_download
    require 'open-uri'
    
    require 'down'
    require "down/net_http"
    zipname = "Suspect_List_#{@suspect_list.name}_#{@suspect_list.id}.zip"
    disposition = "attachment; filename=\"#{zipname}\""
    response.headers["Content-Disposition"] = disposition
    response.headers["Content-Type"] = "application/zip"
    response.headers["Last-Modified"] = Time.now.httpdate.to_s
    response.headers["X-Accel-Buffering"] = "no"
    
    writer = ZipTricks::BlockWrite.new do |chunk| 
      response.stream.write(chunk)
    end
    
    ZipTricks::Streamer.open(writer, auto_rename_duplicate_filenames: true) do |zip|
      @suspect_list.csv_file_table.uniq.each do |row|
        ticket_number = row.first[1]
        images = Image.api_find_all_by_ticket_number(ticket_number, current_user.company, current_yard_id)
        images.each_with_index do |image, index|
          file_name = "/ticket_#{ticket_number}/#{index+1}_ticket_#{ticket_number}_id_#{image['capture_seq_nbr']}#{Rack::Mime::MIME_TYPES.invert[image['content_type']]}"
          zip.write_deflated_file(file_name) do |file_writer|
            file_writer << Down::NetHttp.open(Image.uri(image['azure_url'], current_user.company), ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
          end
        end
      end
    end
  ensure
    response.stream.close
  end

  def images_zip
    @suspect_list.sidekiq_create_zip_file(current_yard_id)
    flash[:success] = "Your suspect list zip file download is being generated! Once finished, an email will be sent to you with a link to your download."
    redirect_to @suspect_list
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_suspect_list
      @suspect_list = SuspectList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def suspect_list_params
      params.require(:suspect_list).permit(:name, :file, :table, :delimiter, :user_id, :company_id)
    end
end
