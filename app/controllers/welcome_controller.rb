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
      
#      @closed_tickets = Ticket.all_last_30_days(1, current_user.token, current_yard_id)
#      @held_tickets = Ticket.all_last_30_days(2, current_user.token, current_yard_id)
#      @paid_tickets = Ticket.all_last_30_days(3, current_user.token, current_yard_id)
      
#      @closed_tickets = Ticket.all_by_date_and_status_and_yard(1, current_user.token, current_yard_id, 30.days.ago, Date.today.yesterday)
#      @held_tickets = Ticket.all_by_date_and_status_and_yard(2, current_user.token, current_yard_id, 30.days.ago, Date.today.yesterday)
#      @paid_tickets = Ticket.all_by_date_and_status_and_yard(3, current_user.token, current_yard_id, 30.days.ago, Date.today.yesterday)
      
#      @closed_and_paid_tickets = @closed_tickets + @paid_tickets
#      @closed_and_held_and_paid_tickets = @closed_tickets + @held_tickets + @paid_tickets
      
#      @closed_tickets_today = Ticket.all_today(1, current_user.token, current_yard_id)
#      @held_tickets_today = Ticket.all_today(2, current_user.token, current_yard_id)
#      @paid_tickets_today = Ticket.all_today(3, current_user.token, current_yard_id)
#      @closed_and_paid_tickets_today = @closed_tickets_today + @paid_tickets_today
      
#      @wait_time = Ticket.average_wait_time(@closed_and_paid_tickets_today)
      
#      @held_tickets_today_total = 0
#      @held_tickets_today.each do |ticket|
#        @held_tickets_today_total = @held_tickets_today_total + (ticket['TicketItemCollection'].blank? ? 0 : Ticket.line_items_total(ticket['TicketItemCollection']['ApiTicketItem'])) 
#      end
      
#      @paid_tickets_today_total = 0
#      @paid_tickets_today.each do |ticket|
#        @paid_tickets_today_total = @paid_tickets_today_total + (ticket['TicketItemCollection'].blank? ? 0 : Ticket.line_items_total(ticket['TicketItemCollection']['ApiTicketItem'])) 
#      end
      
#      @closed_and_paid_tickets_line_items = []
#      unless @closed_and_paid_tickets.blank?
#        @closed_and_paid_tickets.each do |ticket|
#          unless ticket['TicketItemCollection'].blank? or ticket['TicketItemCollection']['ApiTicketItem'].blank?
#            @closed_and_paid_tickets_line_items = @closed_and_paid_tickets_line_items + Ticket.line_items(ticket['TicketItemCollection']['ApiTicketItem'])
#          end
#        end
#      end
      
#      @closed_and_paid_tickets_line_items_net_total = 0
#      @closed_and_paid_tickets_line_items.each do |line_item|
#        @closed_and_paid_tickets_line_items_net_total = @closed_and_paid_tickets_line_items_net_total + line_item["NetWeight"].to_d
#      end
      
#      @closed_and_paid_tickets_today_line_items = []
#      unless @closed_and_paid_tickets_today.blank?
#        @closed_and_paid_tickets_today.each do |ticket|
#          unless ticket['TicketItemCollection'].blank? or ticket['TicketItemCollection']['ApiTicketItem'].blank?
#            if ticket['DateCreated'].to_date == Date.today
#              @closed_and_paid_tickets_today_line_items = @closed_and_paid_tickets_today_line_items + Ticket.line_items(ticket['TicketItemCollection']['ApiTicketItem'])
#            end
#          end
#        end
#      end
      
#      @closed_and_paid_tickets_today_line_items_ferrous_net_total = 0
#      @closed_and_paid_tickets_today_line_items_non_ferrous_net_total = 0
#      @closed_and_paid_tickets_today_line_items.each do |line_item|
#        commodity = Commodity.find_by_id(current_user.token, current_yard_id, line_item["CommodityId"])
#        if commodity and commodity["Type"] == "F"
#          @closed_and_paid_tickets_today_line_items_ferrous_net_total = @closed_and_paid_tickets_today_line_items_ferrous_net_total + line_item["NetWeight"].to_d
#        elsif commodity and commodity["Type"] == "N"
#          @closed_and_paid_tickets_today_line_items_non_ferrous_net_total = @closed_and_paid_tickets_today_line_items_non_ferrous_net_total + line_item["NetWeight"].to_d
#        end
#      end
      
#      @closed_tickets_line_items = []
#      unless @closed_tickets.blank?
#        @closed_tickets.each do |ticket|
#          unless ticket['TicketItemCollection'].blank? or ticket['TicketItemCollection']['ApiTicketItem'].blank?
#            @closed_tickets_line_items = @closed_tickets_line_items + Ticket.line_items(ticket['TicketItemCollection']['ApiTicketItem'])
#          end
#        end
#      end
      
#      @closed_tickets_line_items_ferrous_net_total = 0
#      @closed_tickets_line_items_non_ferrous_net_total = 0
#      @closed_tickets_line_items.each do |line_item|
#        commodity = Commodity.find_by_id(current_user.token, current_yard_id, line_item["CommodityId"])
#        if commodity and commodity["Type"] == "F"
#          @closed_tickets_line_items_ferrous_net_total = @closed_tickets_line_items_ferrous_net_total + line_item["NetWeight"].to_d
#        elsif commodity and commodity["Type"] == "N"
#          @closed_tickets_line_items_non_ferrous_net_total = @closed_tickets_line_items_non_ferrous_net_total + line_item["NetWeight"].to_d
#        end
#      end
      
#      @closed_tickets_today_line_items = []
#      unless @closed_tickets_today.blank?
#        @closed_tickets_today.each do |ticket|
#          unless ticket['TicketItemCollection'].blank? or ticket['TicketItemCollection']['ApiTicketItem'].blank?
#            @closed_tickets_today_line_items = @closed_tickets_today_line_items + Ticket.line_items(ticket['TicketItemCollection']['ApiTicketItem'])
#          end
#        end
#      end
      
#      @closed_tickets_today_line_items_net_total = 0
#      @closed_tickets_today_line_items.each do |line_item|
#        @closed_tickets_today_line_items_net_total = @closed_tickets_today_line_items_net_total + line_item["NetWeight"].to_d
#      end
      
#      @closed_and_held_and_paid_tickets_today = @closed_tickets_today + @held_tickets_today + @paid_tickets_today
#      @closed_and_held_and_paid_tickets_today = @closed_and_held_and_paid_tickets_today.select {|t| t['DateCreated'].to_date == Date.today}.sort_by{|t| t['DateCreated']}.reverse

#      @held_shipments_today = PackShipment.all_held(current_user.token, current_yard_id).last(5)
#      @closed_shipments_today = PackShipment.all_by_date(current_user.token, current_yard_id, Date.today, Date.today)
      
#      @held_shipments_today = PackShipment.all_held_today(current_user.token, current_yard_id)
#      @last_held_shipment_today = @held_shipments_today.sort_by{|s| s['DateCreated']}.last unless @held_shipments_today.blank?
      
#      @closed_shipments_today = PackShipment.all_closed_today(current_user.token, current_yard_id)
#      @last_closed_shipment_today = @closed_shipments_today.sort_by{|s| s['DateShipped']}.last unless @closed_shipments_today.blank?
      
#      @closed_and_held_shipments_today = @held_shipments_today + @closed_shipments_today
#      @closed_and_held_shipments_today = @closed_and_held_shipments_today.select {|t| t['DateCreated'].to_date == Date.today}.sort_by{|t| t['DateCreated']}.reverse
      
#      @held_shipments_today_total_net = 0
#      @held_shipments_today.each do |shipment|
#        @held_shipments_today_total_net = @held_shipments_today_total_net + shipment['NetWeight'].to_d
#      end
      
#      @closed_shipments_today_total_net = 0
#      @closed_shipments_today.each do |shipment|
#        @closed_shipments_today_total_net = @closed_shipments_today_total_net + shipment['NetWeight'].to_d
#      end
      
#      @accounts_payable_items = AccountsPayable.all(current_user.token, @paid_tickets_today.last["YardId"], @paid_tickets_today.last['Id'])
#      @apcashier = Apcashier.find_by_id(current_user.token, @paid_tickets_today.last["YardId"], @accounts_payable_items.first['CashierId'])
    else
      flash[:danger] = 'You do not have access to that page.'
      redirect_to root_path
    end
  end
  
end
