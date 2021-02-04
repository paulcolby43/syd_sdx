class V2::ContainersController < ApplicationController
  before_filter :login_required  
  
  # GET v2/containers
  # GET v2/containers.json
  def index
    authorize! :index, :containers
    @q = params[:q]
    unless @q.blank?
      filter = ' {"or": [{"dispatchContainerNumber": {"eq": ' +  "#{@q.to_i}" + ' }}, {"tagNumber": {"contains": "' +  @q + '" }} ]} '
      results = Container.v2_all_by_filter(filter)
    else
      results = Container.v2_all_by_filter(nil)
    end
    
    respond_to do |format|
      format.json {
        unless results.blank?
          @containers = results.collect{ |container| {id: container.id, text: "#{container.tag_number} (#{container.dispatch_container_number})"} }
        else
          @containers = nil
        end
        Rails.logger.info "results: {#{@containers}}"
        render json: {results: @containers}
      }
    end
  end

  # GET v2/containers/1
  # GET v2/containers/1.json
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
