class ServiceRequestsController < ApplicationController
  before_filter :login_required

  respond_to :html, :js

  def index
  end

  def show
    respond_with(@service_request)
  end

  def new
    authorize! :create, :service_requests
#    @service_request = ServiceRequest.new
    @customers = Customer.all_dispatch(current_user.token, current_yard_id)
#    @task_type_functions = Trip.task_type_functions(current_user.token)
  end

  def edit
  end

  def create
    create_service_request_response = ServiceRequest.create(current_user.token, current_yard_id, service_request_params)
    respond_to do |format|
      format.html {
        if create_service_request_response["Success"] == 'true'
          flash[:success] = 'Service Request was successfully created.'
#          redirect_to service_request_path(create_service_request_response['Item']['Id'])
          redirect_to root_path
        else
          flash[:danger] = 'Error creating Service Request.'
          redirect_to root_path
        end
      }
    end
  end

  def update
    @service_request.update(service_request_params)
    respond_with(@service_request)
  end
  
  def destroy
    @service_request.destroy
    respond_with(@service_request)
  end

  private
    def set_service_request
      @service_request = ServiceRequest.find(params[:id])
    end

    def service_request_params
      params.require(:service_request).permit(ticket_nbr)
    end
end
