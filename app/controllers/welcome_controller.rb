class WelcomeController < ApplicationController
  before_filter :login_required, only: [:kpi_dashboard]
  
  def index
  end
  
  def privacy
  end
  
  def tos
  end
  
  def kpi_dashboard
    @held_tickets_today = Ticket.all_last_90_days(2, current_user.token, current_yard_id)
    @paid_tickets_today = Ticket.all_last_90_days(3, current_user.token, current_yard_id)
    
    @held_shipments_today = PackShipment.all(current_user.token, current_yard_id).last(15)
  end
end
