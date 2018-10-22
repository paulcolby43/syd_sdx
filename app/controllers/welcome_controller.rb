class WelcomeController < ApplicationController
  before_filter :login_required, only: [:kpi_dashboard]
  
  def index
  end
  
  def privacy
  end
  
  def tos
  end
  
  def kpi_dashboard
    @yards = Yard.all(current_user.token)
    unless params[:yard_id].blank?
      @yard = Yard.find_by_id(current_user.token, params[:yard_id])
      session[:yard_id] = params[:yard_id]
      session[:yard_name] = @yard['Name']
    end
    @held_tickets_today = Ticket.all_last_90_days(2, current_user.token, current_yard_id)
    @paid_tickets_today = Ticket.all_last_90_days(3, current_user.token, current_yard_id)
    
    @held_shipments_today = PackShipment.all_held(current_user.token, current_yard_id).last(15)
    @closed_shipments_today = PackShipment.all_by_date(current_user.token, current_yard_id, (Date.today - 4.months), Date.today)
  end
end
