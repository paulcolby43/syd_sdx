class TasksController < ApplicationController
  before_filter :login_required  
  include ApplicationHelper
  include TasksHelper

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
#      @update_task_response = Task.update(current_user.token, task_params)
      @update_task_response = Task.update(current_user.token, task_params)
      @task_status_color = task_status_color(task_params[:status])
      @task_status_string = task_status_string(task_params[:status])
    else
      @container_id = task_params[:container_id]
      @task_id = task_params[:id]
      @update_task_response = Task.add_container(current_user.token, task_params[:id], @container_id, task_params[:latitude], task_params[:longitude])
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
  
  def remove_container
    respond_to do |format|
      format.json { 
        @remove_container_response = Task.remove_container(current_user.token, params[:id], params[:container_id])
        if @remove_container_response["Success"] == "true"
          render json: {results: nil}, :status => :ok
        else
          render json: {error: 'Error removing container'}, status: :unprocessable_entity
        end
        }
    end
  end
  
  def create_new_container
    respond_to do |format|
      format.js {
        @create_new_container_response = Task.create_new_container(current_user.token, params[:id], params[:container])
        if @create_new_container_response["Success"] == "true"
          @task_id = params[:id]
          @container_number = params[:container][:container_number]
          # Get the newly created container's ID from response
          @container_id = @create_new_container_response["ContainerId"]
        else
          @error = @create_new_container_response["FailureInformation"]
        end
      }
    end
  end
  
  def update_container
    respond_to do |format|
      format.json { 
        @update_container_response = Task.update_container(current_user.token, params[:id], params[:container_id], params[:latitude], params[:longitude])
        if @update_container_response["Success"] == "true"
          render json: {results: nil}, :status => :ok
        else
          render json: {error: 'Error updating container'}, status: :unprocessable_entity
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
