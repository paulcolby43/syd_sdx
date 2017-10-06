class BlobsController < ApplicationController
  before_filter :login_required

  respond_to :html, :js

  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end
  
  def show_jpeg_image
    @blob = Blob.api_find_by_id(params[:id], current_user.company)
    send_data @blob['JPEG_IMAGE'], :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def show_preview_image
    @blob = Blob.api_find_by_id(params[:id], current_user.company)
    send_data @blob['PREVIEW'], :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def destroy
    @blob.destroy
    respond_with(@blob)
  end
  
end
