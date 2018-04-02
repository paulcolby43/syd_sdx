class ImagesController < ApplicationController
  before_filter :login_required, :except => [:show_jpeg_image, :show_preview_image]
#  before_action :set_image, only: [:show, :edit, :update, :show_jpeg_image, :show_preview_image, :destroy]
  
#  load_and_authorize_resource :except => [:show_jpeg_image, :show_preview_image]
  load_and_authorize_resource :only => [:show]

  respond_to :html, :js

  def index
    unless params[:q].blank? or params[:today] == true
      @ticket_number = params[:q][:ticket_nbr_eq]
      @event_code = params[:q][:event_code_eq]
      @start_date = params[:q][:sys_date_time_gteq]
      @end_date = params[:q][:sys_date_time_lteq]
      
      if @end_date.present? # Use end date's end of day
        params[:q][:sys_date_time_lteq] = params[:q][:sys_date_time_lteq].to_date.end_of_day
      end
      
      search = Image.ransack(params[:q])
      
      ### Only show one image per ticket by default, unless there is a ticket number being searched ###
      unless @ticket_number.blank?
        params[:one_image_per_ticket] == '0'
        @one_image_per_ticket = '0'
        search.sorts = "sys_date_time desc"
        @images = search.result.page(params[:page]).per(6)
      else
        search.sorts = "ticket_nbr desc"
        if params[:one_image_per_ticket] == '1' or not params[:one_image_per_ticket] == '0'
          @images = search.result
          @images = Kaminari.paginate_array(@images.to_a.uniq { |image| image.ticket_nbr }).page(params[:page]).per(6)
        else
          @images = search.result.page(params[:page]).per(6)
        end
      end
      
    else # Show today's tickets
      # Default search to today's images
      @today = true
      unless current_user.customer?
        search = Image.ransack(:sys_date_time_gteq => Date.today.beginning_of_day, :sys_date_time_lteq => Date.today.end_of_day, :yardid_eq => current_yard_id)
      else
        search = Image.ransack(:cust_nbr_eq => "#{current_user.customer_guid.blank? ? 'fubar' : current_user.customer_guid}", :yardid_eq => "#{current_user.yard_id.blank? ? 'fubar' : current_user.yard_id}", :sys_date_time_gteq => Date.today.beginning_of_day, :sys_date_time_lteq => Date.today.end_of_day)
      end
      params[:q] = {}
      @start_date = Date.today.to_s
      @end_date = Date.today.to_s
      search.sorts = "ticket_nbr desc"
      @images = search.result
      @images = Kaminari.paginate_array(@images.to_a.uniq { |image| image.ticket_nbr }).page(params[:page]).per(6)
    end
  end

  def show
    @image = Image.api_find_by_capture_sequence_number(params[:id], current_user.company, params[:yard_id].blank? ? current_yard_id : params[:yard_id])
    @ticket_number = @image['TICKET_NBR']
    if @image['YARDID'].downcase != current_yard_id.downcase or (current_user.customer? and @image['HIDDEN'] == '1')
      # Don't allow access if yard ID doesn't match, or if customer user and the image is set to hidden
      flash[:danger] = "You don't have access to that page."
      redirect_to root_path
    else
      @blob = Image.jpeg_image(current_user.company, params[:id], current_yard_id)
      if @blob[0..3] == "%PDF"
        # Show pdf directly in the browser
        redirect_to show_jpeg_image_image_path(@image['CAPTURE_SEQ_NBR'])
      end
    end
#    respond_with(@image)
  end

  def new
    @image = Image.new
  end

  def edit
  end

  def create
    @image = Image.new(image_params)
    @image.save
    respond_with(@image)
  end

  def update
    @image.update(image_params)
    respond_with(@image)
  end
  
  def show_jpeg_image
#    send_data @image.jpeg_image, :type => 'image/jpeg',:disposition => 'inline'
    blob = Image.jpeg_image(current_user.company, params[:id], params[:yard_id].blank? ? current_yard_id : params[:yard_id])
    unless blob[0..3] == "%PDF" 
      send_data blob, :type => 'image/jpeg',:disposition => 'inline'
    else
      # PDF file
      send_data blob, :type => 'application/pdf',:disposition => 'inline'
    end
  end
  
  def show_preview_image
#    send_data @image.preview, :type => 'image/jpeg',:disposition => 'inline'
    send_data Image.preview(current_user.company, params[:id], params[:yard_id].blank? ? current_yard_id : params[:yard_id]), :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def send_pdf_data
#    send_data @image.jpeg_image, :type => 'application/pdf',:disposition => 'attachment'
    send_data Image.jpeg_image(current_user.company, params[:id], params[:yard_id].blank? ? current_yard_id : params[:yard_id]), :type => 'application/pdf',:disposition => 'attachment'
  end
  
  def destroy
    @image.destroy
    respond_with(@image)
  end
  
  def advanced_search
    authorize! :advance_search, :images
    unless params[:q].blank?
      @search = Image.search(params[:q].merge(proper_yardid: current_yard_id))
      @images = @search.result.page(params[:page]).per(6)
    else
      # Default search to today's images
      params[:q] = {:cust_nbr_eq => "#{current_user.customer_guid.blank? ? 'fubar' : current_user.customer_guid}", :sys_date_time_gteq => Date.today.beginning_of_day, :sys_date_time_lteq => Date.today.end_of_day, proper_yardid: current_yard_id}
      @search = Image.ransack(params[:q])
      @images = @search.result.page(params[:page]).per(6)
    end
    @search.build_condition if @search.conditions.blank?
  end
  
  private
    def set_image
      @image = Image.find(params[:id])
    end

    def image_params
      params.require(:image).permit(:ticket_nbr)
    end
    
end
