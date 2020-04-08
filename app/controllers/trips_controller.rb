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
    @service_requests = Trip.service_requests(@trip)
    unless @service_requests.blank?
      service_request_task_type = @task_type_functions.find {|task_type_function| task_type_function['Name'] == @service_requests.first['TaskType']}
      @service_request_task_type_id = service_request_task_type['Id'] unless service_request_task_type.blank?
      @customer_id = @service_requests.first['CustomerId']
    end
#    @service_request_task_type_id = @task_type_functions.find {|task_type_function| task_type_function['Name'] == @service_request['TaskType']}['Id']
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
    update_trip_response = Trip.update_driver(current_user.token, params[:id], trip_params[:driver_id])
    respond_to do |format|
      format.html {
        if update_trip_response and update_trip_response["Success"] == 'true'
          flash[:success] = "Trip was successfully updated."
#          redirect_to search_trips_path
          redirect_to :back
        else
          flash[:danger] = 'Error updating Trip.'
#          redirect_to search_trips_path
          redirect_to :back
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
  
  # DELETE /trips/1
  # DELETE /trips/1.json
  def destroy
    void_trip_response = Trip.void(current_user.token, params[:id])
    respond_to do |format|
      format.html {
        if void_trip_response and void_trip_response["Success"] == 'true'
          flash[:success] = "Trip was successfully voided."
          redirect_to :back
        else
          flash[:danger] = 'Error voiding Trip.'
          redirect_to :back
        end
      }
    end
  end
  
  # GET /trips/1/log_location
  # GET /trips/1/log_location.json
  def log_location
    respond_to do |format|
      format.json {
        response = Trip.log_location(current_user.token, params[:id], params[:latitude], params[:longitude])
        unless response.blank?
          if response["Success"] == "true"
            render json: {:continue_logging => response["ContinueLogging"]}, :status => :ok
          else
            render json: {:error => response["FailureInformation"]}, :status => :ok
          end
        else
          render json: {}, status: :unprocessable_entity
#          render json: {error: "Log location failed."}, :status => :bad_request
        end
      }
    end
  end
  
  # GET /trips/1/locations
  # GET /trips/1/locations.json
  def locations
    authorize! :show, :trips
    @trip = Trip.find(current_user.token, params[:id])
    location_results = Trip.get_locations(current_user.token, params[:id])
    @locations = location_results.uniq { |location| [location["Latitude"], location["Longitude"]] }
  end
  
  # GET /trips/drivers
  # GET /trips/drivers.json
  def drivers
    authorize! :index, :trips
    @dispatch_information = Trip.dispatch_info_by_user_guid(current_user.token)
    @trips = Trip.all_by_user(@dispatch_information)
    @driver_locations = []
    @trips.each do |trip|
      locations = Trip.get_locations(current_user.token, trip['Id'])
      @driver_locations << locations.first unless locations.blank?
    end
    @driver_coordinates_hashes_array = []
    @driver_locations.each do |location|
      latitude = location['Latitude'].to_f
      longitude = location['Longitude'].to_f
      trip_number = @trips.find {|trip| trip['Id'] == location['TripId']}['TripNumber']
      truck = @trips.find {|trip| trip['Id'] == location['TripId']}['Truck']
      driver_name = @trips.find {|trip| trip['Id'] == location['TripId']}['Driver']
      @driver_coordinates_hashes_array << {lat: latitude, lng: longitude, name: driver_name, description: "#{driver_name} #{truck} #{trip_number}"}
    end
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
