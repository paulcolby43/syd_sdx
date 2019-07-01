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
      
      @closed_shipments_today = Scoreboard.closed_shipments_today(current_user.token, current_yard_id)
#      @held_shipments_today = Scoreboard.held_shipments_today(current_user.token, current_yard_id)
#      @held_and_closed_shipments_today = @held_shipments_today + @closed_shipments_today
    else
      flash[:danger] = 'You do not have access to that page.'
      redirect_to root_path
    end
  end
  
end
