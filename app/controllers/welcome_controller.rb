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
      @held_tickets_today = Ticket.all_last_90_days(2, current_user.token, current_yard_id).last(5)
      @paid_tickets_today = Ticket.all_last_90_days(3, current_user.token, current_yard_id).last(5)
      
      @held_tickets_today_total = 0
      @held_tickets_today.each do |ticket|
        @held_tickets_today_total = @held_tickets_today_total + (ticket['TicketItemCollection'].blank? ? 0 : Ticket.line_items_total(ticket['TicketItemCollection']['ApiTicketItem'])) 
      end
      
      @paid_tickets_today_total = 0
      @paid_tickets_today.each do |ticket|
        @paid_tickets_today_total = @paid_tickets_today_total + (ticket['TicketItemCollection'].blank? ? 0 : Ticket.line_items_total(ticket['TicketItemCollection']['ApiTicketItem'])) 
      end

      @held_shipments_today = PackShipment.all_held(current_user.token, current_yard_id).last(5)
      @closed_shipments_today = PackShipment.all_by_date(current_user.token, current_yard_id, (Date.today - 4.months), Date.today).last(5)
      
#      @accounts_payable_items = AccountsPayable.all(current_user.token, @paid_tickets_today.last["YardId"], @paid_tickets_today.last['Id'])
#      @apcashier = Apcashier.find_by_id(current_user.token, @paid_tickets_today.last["YardId"], @accounts_payable_items.first['CashierId'])
    else
      flash[:danger] = 'You do not have access to that page.'
      redirect_to root_path
    end
  end
  
end
