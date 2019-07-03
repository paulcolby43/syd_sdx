class WelcomeController < ApplicationController
  before_filter :login_required, only: [:kpi_dashboard]
  
  def index
  end
  
  def privacy
  end
  
  def tos
  end
  
  def kpi_dashboard
    if current_user.admin?
      @yards = Yard.all(current_user.token)
      unless params[:yard_id].blank?
        @yard = Yard.find_by_id(current_user.token, params[:yard_id])
        session[:yard_id] = params[:yard_id]
        session[:yard_name] = @yard['Name']
      end
      
      @tickets_created = Scoreboard.tickets_created(current_user.token, current_yard_id)
      @tickets_today = @tickets_created['TicketsCreatedToday'] unless @tickets_created.blank?
      @tickets_30_days = @tickets_created['TicketsCreatedMultiDayTotal'] unless @tickets_created.blank?
      
      @tickets_on_hold = Scoreboard.tickets_on_hold(current_user.token, current_yard_id)
      @tickets_on_hold_total = @tickets_on_hold['TicketsOnHold'] unless @tickets_on_hold.blank?
      @average_hold_time = @tickets_on_hold['AverageHoldTime'] unless @tickets_on_hold.blank?
      
      @paid_tickets_today_data = Scoreboard.paid_tickets_today_data(current_user.token, current_yard_id)
      @paid_tickets_today_count = @paid_tickets_today_data['PaidTickets']
      @paid_tickets_today_amount = @paid_tickets_today_data['PaidTicketsAmount']
      
      @commodity_totals_by_type = Scoreboard.commodity_totals_by_type(current_user.token, current_yard_id)
      
      @held_shipments_count = Scoreboard.held_shipments_count(current_user.token, current_yard_id)
      @sent_shipments_count = Scoreboard.sent_shipments_count(current_user.token, current_yard_id)
      
      @held_tickets_today = Scoreboard.held_tickets_today(current_user.token, current_yard_id)
      @closed_tickets_today = Scoreboard.closed_tickets_today(current_user.token, current_yard_id)
      @paid_tickets_today = Scoreboard.paid_tickets_today(current_user.token, current_yard_id)
      @closed_and_held_and_paid_tickets_today = @held_tickets_today + @closed_tickets_today + @paid_tickets_today
      
      unless @held_shipments_count == '0' and @sent_shipments_count == '0'
        @last_10_shipments = PackShipment.all(current_user.token, current_yard_id, 10)
        @held_shipment = PackShipment.number_of_held(current_user.token, current_yard_id, 1).first
        @closed_shipment = PackShipment.number_of_closed(current_user.token, current_yard_id, 1).first
      end
      
    else
      flash[:danger] = 'You do not have access to that page.'
      redirect_to root_path
    end
  end
  
end
