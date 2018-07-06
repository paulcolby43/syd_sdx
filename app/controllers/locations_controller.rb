class LocationsController < ApplicationController
  before_filter :login_required  

  # GET /locations/1
  # GET /locations/1.json
  def show
    authorize! :show, :locations
    @location_id = params[:id]
    @location_address = params[:address]
    @work_order_number= params[:work_order_number]
    @containers = Location.containers(current_user.token, params[:id])
  end
  
  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.require(:location).permit(:id)
    end
end
