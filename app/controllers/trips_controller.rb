class TripsController < ApplicationController
  before_filter :login_required  
  include ApplicationHelper

  # GET /trips
  # GET /trips.json
  def index
    authorize! :index, :trips
    @dispatch_information = Trip.dispatch_info_by_user_guid(current_user.token)
    @trips = Trip.all_by_user(@dispatch_information)
#    @trucks = Trip.all_trucks(@dispatch_information)
    @containers = Container.all_by_dispatch_information(@dispatch_information)
    @task_functions = Trip.task_functions(@dispatch_information)
    @container_types = Trip.container_types(@dispatch_information)
  end
  
  # GET /trips/1
  # GET /trips/1.json
  def show
    authorize! :show, :trips
#    @trip = Trip.find_by_user_guid(current_user.token, params[:id])
#    @tasks = Trip.tasks(@trip)
    @trip = Trip.find(current_user.token, params[:id])
    @drivers = Trip.drivers(current_user.token)
    @driver = @drivers.find {|driver| driver['Id'] == @trip['DriverId']}
    @service_requests = Trip.service_requests(@trip)
    @tasks = Trip.service_request_tasks(@trip)
  end
  
  def new
    authorize! :create, :trips
    @customers = Customer.all_dispatch(current_user.token, current_yard_id)
    @task_type_functions = Trip.task_type_functions(current_user.token)
    @drivers = Trip.drivers(current_user.token)
  end

  def edit
    authorize! :edit, :trips
    @trip = Trip.find(current_user.token, params[:id])
    @customers = Customer.all_dispatch(current_user.token, current_yard_id)
    @task_type_functions = Trip.task_type_functions(current_user.token)
    @drivers = Trip.drivers(current_user.token)
    @service_request = Trip.service_requests(@trip).last
    @service_request_task_type_id = @task_type_functions.find {|task_type_function| task_type_function['Name'] == @service_request['TaskType']}['Id']
  end

  def create
    create_trip_response = Trip.create(current_user.token, current_yard_id, trip_params[:driver_id], trip_params[:customer_id], trip_params[:task_type_function_id])
    respond_to do |format|
      format.html {
        if create_trip_response and create_trip_response["Success"] == 'true'
          flash[:success] = "Trip was successfully created. Service Request: #{create_trip_response['WorkOrderNumber']}"
          redirect_to search_trips_path
        else
          flash[:danger] = 'Error creating Trip.'
          redirect_to search_trips_path
        end
      }
    end
  end

  def update
    update_trip_response = Trip.create(current_user.token, current_yard_id, trip_params[:driver_id], trip_params[:customer_id], trip_params[:task_type_function_id])
    respond_to do |format|
      format.html {
        if update_trip_response and update_trip_response["Success"] == 'true'
          flash[:success] = "Trip was successfully updated."
          redirect_to search_trips_path
        else
          flash[:danger] = 'Error updating Trip.'
          redirect_to search_trips_path
        end
      }
    end
  end

  def search
    authorize! :search, :trips
    @status = trip_params[:status] == 'All' ? nil : trip_params[:status] # Default status to All
    @driver_id = trip_params[:driver_id] == 'All' ? nil : trip_params[:driver_id] # Default drivers to All
    @start_date = trip_params[:start_date].blank? ? Date.today.to_s : trip_params[:start_date]# Default to today
    @trips = Trip.search(current_user.token, @status, @driver_id, @start_date)
    @drivers = Trip.drivers(current_user.token)
  end
  
  private

    # Never trust parameters from the scary internet, only allow the white list through.
#    def trip_params
#      params.require(:trip).permit(:id, :description, :quantity, :net)
#    end
    
    def trip_params
      params.fetch(:trip, {}).permit(:customer_id, :task_type_function_id, :driver_id, :status, :start_date)
    end
end
