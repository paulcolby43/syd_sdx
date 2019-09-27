class TicketInfoSendEmailWorker
  include Sidekiq::Worker
  
  def perform(user_id, ticket_id, yard_id, recipients)
    user = User.find(user_id)
    ticket = Ticket.find_by_id(user.token, yard_id, ticket_id)
    ticket_number = ticket["TicketNumber"]
    unless ticket["TicketItemCollection"].blank?
      unless ticket["TicketItemCollection"]["ApiTicketItem"].is_a? Hash
        line_items = ticket["TicketItemCollection"]["ApiTicketItem"].select {|i| i["Status"] == '0'} 
      else
        if ticket["TicketItemCollection"]["ApiTicketItem"]["Status"] == '0'
          line_items = [ticket["TicketItemCollection"]["ApiTicketItem"]]
        end
      end
    end
    if user.view_images?
      images_array = Image.api_find_all_by_ticket_number(ticket_number, user.company, ticket["YardId"]).reverse # Ticket images
      rt_lookups = RtLookup.api_find_all_by_ticket_number(ticket_number, user.company, ticket["YardId"])
      rt_lookups.each do |rt_lookup|
        rt_lookup_images = Image.api_find_all_by_receipt_number(rt_lookup['RECEIPT_NBR'], user.company, ticket["YardId"]).reverse
        images_array =  images_array | rt_lookup_images # Union the image arrays
      end
    else
      images_array = []
    end
    UserMailer.ticket_information(user, ticket, line_items, recipients, images_array).deliver
  end
end