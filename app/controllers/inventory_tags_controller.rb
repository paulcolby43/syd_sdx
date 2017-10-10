class InventoryTagsController < ApplicationController
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
      
      search = InventoryTag.ransack(params[:q])
      
      ### Only show one inventory_tag per ticket by default, unless there is a ticket number being searched ###
      unless @ticket_number.blank?
        params[:one_inventory_tag_per_ticket] == '0'
        @one_inventory_tag_per_ticket = '0'
        search.sorts = "sys_date_time desc"
        @inventory_tags = search.result.page(params[:page]).per(6)
      else
        search.sorts = "ticket_nbr desc"
        if params[:one_inventory_tag_per_ticket] == '1' or not params[:one_inventory_tag_per_ticket] == '0'
          @inventory_tags = search.result
          @inventory_tags = Kaminari.paginate_array(@inventory_tags.to_a.uniq { |inventory_tag| inventory_tag.ticket_nbr }).page(params[:page]).per(6)
        else
          @inventory_tags = search.result.page(params[:page]).per(6)
        end
      end
      
    else # Show today's tickets
      # Default search to today's inventory_tags
      @today = true
      search = InventoryTag.ransack(:sys_date_time_gteq => Date.today.beginning_of_day, :sys_date_time_lteq => Date.today.end_of_day, :yardid_eq => current_yard_id)
      params[:q] = {}
      @start_date = Date.today.to_s
      @end_date = Date.today.to_s
      search.sorts = "ticket_nbr desc"
      @inventory_tags = search.result
      @inventory_tags = Kaminari.paginate_array(@inventory_tags.to_a.uniq { |inventory_tag| inventory_tag.ticket_nbr }).page(params[:page]).per(6)
    end
  end

  def show
    @inventory_tag = InventoryTag.api_find_by_capture_sequence_number(params[:id], current_user.company)
    @ticket_number = @inventory_tag['TICKET_NBR']
    if @inventory_tag['YARDID'] != current_yard_id
      flash[:danger] = "You don't have access to that page."
      redirect_to root_path
    end
#    respond_with(@inventory_tag)
  end

  def new
    @inventory_tag = InventoryTag.new
  end

  def edit
  end

  def create
    @inventory_tag = InventoryTag.new(inventory_tag_params)
    @inventory_tag.save
    respond_with(@inventory_tag)
  end

  def update
    @inventory_tag.update(inventory_tag_params)
    respond_with(@inventory_tag)
  end
  
  def show_jpeg_image
    send_data InventoryTag.jpeg_image(current_user.company, params[:id]), :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def show_preview_image
    send_data InventoryTag.preview(current_user.company, params[:id]), :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def destroy
    @inventory_tag.destroy
    respond_with(@inventory_tag)
  end

  private
    def set_inventory_tag
      @inventory_tag = InventoryTag.find(params[:id])
    end

    def inventory_tag_params
      params.require(:inventory_tag).permit(ticket_nbr)
    end
end
