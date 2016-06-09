class SendTicketToLeadsWorker
  include Sidekiq::Worker
  
  def perform(access_token, path_to_file, ticket_id, yard_id, user_id)
    require 'net/ftp'
    
    ticket = Ticket.find_by_id(3, access_token, yard_id, ticket_id)
    user = User.find(user_id)
    images = Image.where(ticket_nbr: ticket['TicketNumber'], yardid: yard_id)
    
    File.open(path_to_file, 'w') {|f| f.write(Ticket.generate_leads_online_xml(access_token, ticket_id, yard_id, user, ticket['CustomerId'], images)) }
#    Net::FTP.open('ftp.leadsonline.com', 'tranact', 'tr@n@ct33710') do |ftp|
    Net::FTP.open('ftp.leadsonline.com', user.company.leads_online_ftp_username, user.company.leads_online_ftp_password) do |ftp|
      ftp.passive = true;
      ftp.putbinaryfile(path_to_file);
    end
#    bill_payment.private_note = "Sent to Leads Online"
#    bill_payment = bill_payment_service.update(bill_payment)
  end
  
end