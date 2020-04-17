class ShipmentsController < ApplicationController
  before_filter :login_required, :except => [:show_jpeg_image, :show_preview_image]
#  before_action :set_shipment, only: [:show, :edit, :update, :show_jpeg_image, :show_preview_image, :destroy]
  
#  load_and_authorize_resource :except => [:show_jpeg_image, :show_preview_image]

  respond_to :html, :js

  def index
    unless params[:q].blank? or params[:today] == true
      @ticket_number = params[:q][:ticket_nbr_eq]
      @start_date = params[:q][:sys_date_time_gteq]
      @end_date = params[:q][:sys_date_time_lteq]
      
      if @end_date.present? # Use end date's end of day
        params[:q][:sys_date_time_lteq] = params[:q][:sys_date_time_lteq].to_date.end_of_day
      end
      
      search = Shipment.ransack(params[:q])
      
      ### Only show one shipment per ticket by default, unless there is a ticket number being searched ###
      unless @ticket_number.blank?
        params[:one_shipment_per_ticket] == '0'
        @one_shipment_per_ticket = '0'
        search.sorts = "sys_date_time desc"
        @shipments = search.result.page(params[:page]).per(6)
      else
        search.sorts = "ticket_nbr desc"
        if params[:one_shipment_per_ticket] == '1' or not params[:one_shipment_per_ticket] == '0'
          @shipments = search.result
          @shipments = Kaminari.paginate_array(@shipments.to_a.uniq { |shipment| shipment.ticket_nbr }).page(params[:page]).per(6)
        else
          @shipments = search.result.page(params[:page]).per(6)
        end
      end
      
    else # Show today's tickets
      # Default search to today's shipments
      @today = true
      search = Shipment.ransack(:sys_date_time_gteq => Date.today.beginning_of_day, :sys_date_time_lteq => Date.today.end_of_day, :yardid_eq => current_yard_id)
      params[:q] = {}
      @start_date = Date.today.to_s
      @end_date = Date.today.to_s
      search.sorts = "ticket_nbr desc"
      @shipments = search.result
      @shipments = Kaminari.paginate_array(@shipments.to_a.uniq { |shipment| shipment.ticket_nbr }).page(params[:page]).per(6)
    end
  end

  def show
    @shipment = Shipment.api_find_by_capture_sequence_number(params[:id], current_user.company, params[:yard_id].blank? ? current_yard_id : params[:yard_id])
    @ticket_number = @shipment['TICKET_NBR']
    if @shipment['YARDID'] != current_yard_id or (current_user.customer? and @shipment['HIDDEN'] == '1')
      # Don't allow access if yard ID doesn't match, or if customer user and the shipment image is set to hidden
      flash[:danger] = "You don't have access to that page."
      redirect_to root_path
    else
      @blob = Shipment.jpeg_image(current_user.company, params[:id], current_yard_id)
      if @blob[0..3] == "%PDF"
        # Show pdf directly in the browser
        redirect_to show_jpeg_image_shipment_path(@shipment['CAPTURE_SEQ_NBR'])
      end
    end
#    respond_with(@shipment)
  end

  def new
    @shipment = Shipment.new
  end

  def edit
  end

  def create
    @shipment = Shipment.new(shipment_params)
    @shipment.save
    respond_with(@shipment)
  end

  def update
    @shipment.update(shipment_params)
    respond_with(@shipment)
  end
  
  def show_jpeg_image
#    send_data @shipment.jpeg_image, :type => 'image/jpeg',:disposition => 'inline'
    blob = Shipment.jpeg_image(current_user.company, params[:id], current_yard_id)
    unless blob[0..3] == "%PDF" 
      send_data blob, :type => 'image/jpeg',:disposition => 'inline'
    else
      # PDF file
      send_data blob, :type => 'application/pdf',:disposition => 'inline'
    end
  end
  
  def show_preview_image
#    send_data @shipment.preview, :type => 'image/jpeg',:disposition => 'inline'
    send_data Shipment.preview(current_user.company, params[:id], params[:yard_id].blank? ? current_yard_id : params[:yard_id]), :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def destroy
    @shipment.destroy
    respond_with(@shipment)
  end

  private
    def set_shipment
      @shipment = Shipment.find(params[:id])
    end

    def shipment_params
      params.require(:shipment).permit(ticket_nbr)
    end
end
