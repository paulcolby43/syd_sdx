class ContainersController < ApplicationController
  before_filter :login_required  

  # GET /containers/1
  # GET /containers/1.json
  def show
    authorize! :show, :containers
    @container = Container.find_by_id(current_user.token, params[:id])
    @container_number = @container['UserDispatchContainerNumber']
    @work_order_number = params[:work_order_number]
    @images = Image.api_find_all_by_container_number_and_service_request_number(@container_number, @work_order_number, current_user.company, current_yard_id)
  end
  
  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def container_params
      params.require(:container).permit(:id)
    end
end
