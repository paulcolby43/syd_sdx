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
      
      @closed_tickets = Ticket.all_last_30_days(1, current_user.token, current_yard_id)
      @held_tickets = Ticket.all_last_30_days(2, current_user.token, current_yard_id)
      @paid_tickets = Ticket.all_last_30_days(3, current_user.token, current_yard_id)
      
      @closed_and_held_and_paid_tickets = @closed_tickets + @held_tickets + @paid_tickets
      
      @closed_tickets_today = Ticket.all_today(1, current_user.token, current_yard_id)
      @held_tickets_today = Ticket.all_today(2, current_user.token, current_yard_id)
      @paid_tickets_today = Ticket.all_today(3, current_user.token, current_yard_id)
      
      @held_tickets_today_total = 0
      @held_tickets_today.each do |ticket|
        @held_tickets_today_total = @held_tickets_today_total + (ticket['TicketItemCollection'].blank? ? 0 : Ticket.line_items_total(ticket['TicketItemCollection']['ApiTicketItem'])) 
      end
      
      @paid_tickets_today_total = 0
      @paid_tickets_today.each do |ticket|
        @paid_tickets_today_total = @paid_tickets_today_total + (ticket['TicketItemCollection'].blank? ? 0 : Ticket.line_items_total(ticket['TicketItemCollection']['ApiTicketItem'])) 
      end
      
      @paid_tickets_line_items = []
      unless @paid_tickets.blank?
        @paid_tickets.each do |ticket|
          unless ticket['TicketItemCollection'].blank? or ticket['TicketItemCollection']['ApiTicketItem'].blank?
            @paid_tickets_line_items = @paid_tickets_line_items + Ticket.line_items(ticket['TicketItemCollection']['ApiTicketItem'])
          end
        end
      end
      
      @paid_tickets_line_items_net_total = 0
      @paid_tickets_line_items.each do |line_item|
        @paid_tickets_line_items_net_total = @paid_tickets_line_items_net_total + line_item["NetWeight"].to_d
      end
      
      @paid_tickets_today_line_items = []
      unless @paid_tickets_today.blank?
        @paid_tickets_today.each do |ticket|
          unless ticket['TicketItemCollection'].blank? or ticket['TicketItemCollection']['ApiTicketItem'].blank?
            @paid_tickets_today_line_items = @paid_tickets_today_line_items + Ticket.line_items(ticket['TicketItemCollection']['ApiTicketItem'])
          end
        end
      end
      
      @paid_tickets_today_line_items_net_total = 0
      @paid_tickets_today_line_items.each do |line_item|
        @paid_tickets_today_line_items_net_total = @paid_tickets_today_line_items_net_total + line_item["NetWeight"].to_d
      end
      
      @closed_and_held_and_paid_tickets_today = @closed_tickets_today + @held_tickets_today + @paid_tickets_today

#      @held_shipments_today = PackShipment.all_held(current_user.token, current_yard_id).last(5)
#      @closed_shipments_today = PackShipment.all_by_date(current_user.token, current_yard_id, Date.today, Date.today)
      
      @held_shipments_today = PackShipment.all_held_today(current_user.token, current_yard_id)
      @last_held_shipment_today = @held_shipments_today.sort_by{|s| s['DateCreated']}.last unless @held_shipments_today.blank?
      
      @closed_shipments_today = PackShipment.all_closed_today(current_user.token, current_yard_id)
      @last_closed_shipment_today = @closed_shipments_today.sort_by{|s| s['DateShipped']}.last unless @closed_shipments_today.blank?
      
      @held_shipments_today_total_net = 0
      @held_shipments_today.each do |shipment|
        @held_shipments_today_total_net = @held_shipments_today_total_net + shipment['NetWeight'].to_d
      end
      
      @closed_shipments_today_total_net = 0
      @closed_shipments_today.each do |shipment|
        @closed_shipments_today_total_net = @closed_shipments_today_total_net + shipment['NetWeight'].to_d
      end
      
#      @accounts_payable_items = AccountsPayable.all(current_user.token, @paid_tickets_today.last["YardId"], @paid_tickets_today.last['Id'])
#      @apcashier = Apcashier.find_by_id(current_user.token, @paid_tickets_today.last["YardId"], @accounts_payable_items.first['CashierId'])
    else
      flash[:danger] = 'You do not have access to that page.'
      redirect_to root_path
    end
  end
  
end
