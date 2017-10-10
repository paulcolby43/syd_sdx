class InvTagsController < ApplicationController
  before_filter :login_required, :except => [:show_jpeg_image, :show_preview_image]

  respond_to :html, :js

  def index
    unless params[:q].blank? or params[:today] == true
      @ticket_number = params[:q][:ticket_nbr_eq]
      @start_date = params[:q][:sys_date_time_gteq]
      @end_date = params[:q][:sys_date_time_lteq]
      
      if @end_date.present? # Use end date's end of day
        params[:q][:sys_date_time_lteq] = params[:q][:sys_date_time_lteq].to_date.end_of_day
      end
      
      search = InvTag.ransack(params[:q])
      
      ### Only show one inv_tag per ticket by default, unless there is a ticket number being searched ###
      unless @ticket_number.blank?
        params[:one_inv_tag_per_ticket] == '0'
        @one_inv_tag_per_ticket = '0'
        search.sorts = "sys_date_time desc"
        @inv_tags = search.result.page(params[:page]).per(6)
      else
        search.sorts = "ticket_nbr desc"
        if params[:one_inv_tag_per_ticket] == '1' or not params[:one_inv_tag_per_ticket] == '0'
          @inv_tags = search.result
          @inv_tags = Kaminari.paginate_array(@inv_tags.to_a.uniq { |inv_tag| inv_tag.ticket_nbr }).page(params[:page]).per(6)
        else
          @inv_tags = search.result.page(params[:page]).per(6)
        end
      end
      
    else # Show today's tickets
      # Default search to today's inv_tags
      @today = true
      search = InvTag.ransack(:sys_date_time_gteq => Date.today.beginning_of_day, :sys_date_time_lteq => Date.today.end_of_day, :yardid_eq => current_yard_id)
      params[:q] = {}
      @start_date = Date.today.to_s
      @end_date = Date.today.to_s
      search.sorts = "ticket_nbr desc"
      @inv_tags = search.result
      @inv_tags = Kaminari.paginate_array(@inv_tags.to_a.uniq { |inv_tag| inv_tag.ticket_nbr }).page(params[:page]).per(6)
    end
  end

  def show
    @inv_tag = InvTag.api_find_by_capture_sequence_number(params[:id], current_user.company)
    @ticket_number = @inv_tag['TICKET_NBR']
    if @inv_tag['YARDID'] != current_yard_id
      flash[:danger] = "You don't have access to that page."
      redirect_to root_path
    end
#    respond_with(@inv_tag)
  end

  def new
    @inv_tag = InvTag.new
  end

  def edit
  end

  def create
    @inv_tag = InvTag.new(inv_tag_params)
    @inv_tag.save
    respond_with(@inv_tag)
  end

  def update
    @inv_tag.update(inv_tag_params)
    respond_with(@inv_tag)
  end
  
  def show_jpeg_image
    send_data InvTag.jpeg_image(current_user.company, params[:id]), :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def show_preview_image
    send_data InvTag.preview(current_user.company, params[:id]), :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def destroy
    @inv_tag.destroy
    respond_with(@inv_tag)
  end

  private
    def set_inv_tag
      @inv_tag = InvTag.find(params[:id])
    end

    def inv_tag_params
      params.require(:inv_tag).permit(ticket_nbr)
    end
end
