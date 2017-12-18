class TasksController < ApplicationController
  before_filter :login_required  
  include ApplicationHelper

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    authorize! :show, :tasks
    @task = params[:task]
    @dispatch_information = Trip.dispatch_info_by_user_guid(current_user.token)
    @trips = Trip.all_trips(@dispatch_information)
#    @trip = Trip.find(current_user.token, params[:trip_id])
    @trip = Trip.find_in_trips(@trips, params[:trip_id])
    @workorders = Trip.workorders(@trip)
    @task_workorder = @workorders.find {|workorder| workorder['Id'] == @task['WorkOrderId']}
    @task_containers = Task.containers(@task)
    @all_containers = Container.all_by_dispatch_information(@dispatch_information)
    @task_functions = Trip.task_functions(@dispatch_information)
    @images = nil
    
  end
  
  # GET /tasks/1/edit
  def edit
    authorize! :edit, :tasks
    @task = params[:task]
    @trip = Trip.find(current_user.token, params[:trip_id])
    @workorders = Trip.workorders(@trip)
    @workorder = @workorders.find {|workorder| workorder['Id'] == @task['WorkOrderId']}
    @containers = Task.containers(@task)
    @images = nil
  end
  
  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    @task = task_params
    if task_params[:container_id].blank?
      @update_task_response = Task.update(current_user.token, task_params)
    else
      @update_task_response = Task.add_container(current_user.token, task_params)
      @container_id = task_params[:container_id]
    end
    respond_to do |format|
      format.html {
        if @update_task_response["Success"] == 'true'
          flash[:success] = 'Task was successfully updated.'
          redirect_to trip_path(task_params[:trip_id])
        else
          flash[:danger] = @update_task_response["FailureInformation"]
          redirect_to trip_path(task_params[:trip_id])
        end
      }
      format.js {
        if @update_task_response["Success"] == 'true'
          @response = 'Task was successfully updated.'
        else
          @response = @update_task_response["FailureInformation"]
        end
      }
    end
  end

  
  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:id, :starting_mileage, :ending_mileage, :notes, :status, :container_id, :trip_id)
    end
end
