class CustPicsController < ApplicationController
  before_filter :login_required, :except => [:show_jpeg_image, :show_preview_image]
#  before_action :set_cust_pic, only: [:show, :edit, :update, :show_jpeg_image, :show_preview_image, :destroy]
  
#  load_and_authorize_resource :except => [:show_jpeg_image, :show_preview_image]

  respond_to :html, :js

  def index
    unless params[:q].blank? or params[:today] == true
      @start_date = params[:q][:sys_date_time_gteq]
      @end_date = params[:q][:sys_date_time_lteq]
      
      if (@start_date.present? and @end_date.present?) and (@start_date == @end_date) # User select the same date for both
        params[:q][:sys_date_time_lteq] = params[:q][:sys_date_time_lteq].to_date.tomorrow.strftime("%Y-%m-%d") 
      end
      
      search = CustPic.ransack(params[:q])
#      search.sorts = "#{sort} #{direction}"
      
      @cust_pics = search.result.page(params[:page]).per(6)
      
    else # Show today's tickets
      # Default search to today's cust_pics
      @today = true
#      search = CustPic.ransack(:sys_date_time_gteq => Date.today, :sys_date_time_lteq => Date.today.tomorrow)
      search = CustPic.ransack(:sys_date_time_gteq => Date.today.beginning_of_day, :sys_date_time_lteq => Date.today.end_of_day)
      params[:q] = {}
      @start_date = Date.today.to_s
#      @end_date = Date.today.tomorrow.to_s
      @end_date = Date.today.to_s
#      search.sorts = "sys_date_time desc"
#      search.sorts = "ticket_nbr desc"
      @cust_pics = search.result
      @cust_pics = Kaminari.paginate_array(@cust_pics).page(params[:page]).per(6)
    end
  end

  def show
#    respond_with(@cust_pic)
    @cust_pic = CustPic.api_find_by_capture_sequence_number(params[:id], current_user.company)
    if @cust_pic['YARDID'] != current_yard_id
      flash[:danger] = "You don't have access to that page."
      redirect_to root_path
    end
  end

  def new
    @cust_pic = CustPic.new
  end

  def edit
  end

  def create
    @cust_pic = CustPic.new(cust_pic_params)
    @cust_pic.save
    respond_with(@cust_pic)
  end

  def update
    @cust_pic.update(cust_pic_params)
    respond_with(@cust_pic)
  end
  
  def show_jpeg_image
#    send_data @cust_pic.jpeg_image, :type => 'image/jpeg',:disposition => 'inline'
    send_data CustPic.jpeg_image(current_user.company, params[:id]), :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def show_preview_image
#    send_data @cust_pic.preview, :type => 'image/jpeg',:disposition => 'inline'
    send_data CustPic.preview(current_user.company, params[:id]), :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def destroy
    @cust_pic.destroy
    respond_with(@cust_pic)
  end
  
  def send_pdf_data
    send_data @cust_pic.jpeg_image, :type => 'application/pdf',:disposition => 'attachment'
  end

  private
    def set_cust_pic
      @cust_pic = CustPic.find(params[:id])
    end

    def cust_pic_params
#      params.require(:cust_pic).permit(:ticket_nbr)
    end
    
end
