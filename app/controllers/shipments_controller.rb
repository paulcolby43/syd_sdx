class ShipmentsController < ApplicationController
  before_filter :login_required, :except => [:show_jpeg_image, :show_preview_image]
  before_action :set_shipment, only: [:show, :edit, :update, :show_jpeg_image, :show_preview_image, :destroy]
  
  load_and_authorize_resource :except => [:show_jpeg_image, :show_preview_image]

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
    @ticket_number = @shipment.ticket_nbr
    respond_with(@shipment)
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
    send_data @shipment.jpeg_image, :type => 'image/jpeg',:disposition => 'inline'
  end
  
  def show_preview_image
    send_data @shipment.preview, :type => 'image/jpeg',:disposition => 'inline'
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