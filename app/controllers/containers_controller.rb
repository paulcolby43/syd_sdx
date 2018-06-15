class ContainersController < ApplicationController
  before_filter :login_required  
  include ApplicationHelper
  include ContainersHelper

  # GET /containers/1
  # GET /containers/1.json
  def show
    authorize! :show, :containers
    @container = params[:container]
  end
  
  # GET /containers/1/edit
  def edit
    authorize! :edit, :containers
    @container = params[:container]
    @trip = Trip.find(current_user.token, params[:trip_id])
    @workorders = Trip.workorders(@trip)
    @workorder = @workorders.find {|workorder| workorder['Id'] == @container['WorkOrderId']}
    @containers = Container.containers(@container)
    @images = nil
  end
  
  # PATCH/PUT /containers/1
  # PATCH/PUT /containers/1.json
  def update
    @container = container_params
    if container_params[:container_id].blank?
#      @update_container_response = Container.update(current_user.token, container_params)
      @update_container_response = Container.update(current_user.token, container_params)
      @container_status_color = container_status_color(container_params[:status])
      @container_status_string = container_status_string(container_params[:status])
    else
      @container_id = container_params[:container_id]
      @container_number = container_params[:container_number]
      @customer = container_params[:customer]
      @work_order_number = container_params[:work_order_number]
      @container_type_string = container_type_string(container_params[:type])
      @container_id = container_params[:id]
      @update_container_response = Container.add_container(current_user.token, container_params[:id], @container_id, container_params[:latitude], container_params[:longitude])
    end
    respond_to do |format|
      format.html {
        if @update_container_response["Success"] == 'true'
          flash[:success] = 'Container was successfully updated.'
          redirect_to trip_path(container_params[:trip_id])
        else
          flash[:danger] = @update_container_response["FailureInformation"]
          redirect_to trip_path(container_params[:trip_id])
        end
      }
      format.js {
        if @update_container_response["Success"] == 'true'
          @response = 'Container was successfully updated.'
        else
          @response = @update_container_response["FailureInformation"]
        end
      }
    end
  end
  
  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def container_params
      params.require(:container).permit(:id, :starting_mileage, :ending_mileage, :notes, :status, :container_id, :container_number, :trip_id, :customer, :work_order_number, :type)
    end
end
