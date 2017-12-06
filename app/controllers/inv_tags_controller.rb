class InvTagsController < ApplicationController
  before_filter :login_required, :except => [:show_jpeg_image, :show_preview_image]

  respond_to :html, :js

  def index
  end

  def show
    @inv_tag = InvTag.api_find_by_capture_sequence_number(params[:id], current_user.company, current_yard_id)
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
    send_data InvTag.jpeg_image(current_user.company, params[:id], current_yard_id), :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def show_preview_image
    send_data InvTag.preview(current_user.company, params[:id], current_yard_id), :type => 'image/jpeg',:disposition => 'inline'
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
