class TasksController < ApplicationController
  before_filter :login_required  
  include ApplicationHelper

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    authorize! :show, :tasks
    @task = params[:task]
    @trip = Trip.find(current_user.token, params[:trip_id])
    @workorders = Trip.workorders(@trip)
    @workorder = @workorders.find {|workorder| workorder['Id'] == @task['WorkOrderId']}
    @containers = Task.containers(@task)
    
  end

  
  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:id, :description, :quantity, :net)
    end
end
