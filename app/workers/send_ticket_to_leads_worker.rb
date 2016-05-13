class SendTicketToLeadsWorker
  include Sidekiq::Worker
  
  def perform(access_token, path_to_file, ticket_id, current_company_id, user_id, customer_id)
    require 'net/ftp'
    
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, access_token, access_secret)
    
    company_info_service = Quickbooks::Service::CompanyInfo.new
    company_info_service.access_token = oauth_client
    company_info_service.company_id = current_company_id
    company_info = company_info_service.fetch_by_id(current_company_id)
    
    bill_service = Quickbooks::Service::Bill.new
    bill_service.access_token = oauth_client
    bill_service.company_id = current_company_id
    
    bill_payment_service = Quickbooks::Service::BillPayment.new
    bill_payment_service.access_token = oauth_client
    bill_payment_service.company_id = current_company_id
    
    item_service = Quickbooks::Service::Item.new
    item_service.access_token = oauth_client
    item_service.company_id = current_company_id
    
    bill = bill_service.fetch_by_id(bill_id)
    bill_payment = bill_payment_service.fetch_by_id(bill_payment_id)
    
    user = User.find(user_id)
    customer = Customer.find(customer_id)
    images = Image.where(ticket_nbr: bill_payment.doc_number, location: current_company_id)
    
    File.open(path_to_file, 'w') {|f| f.write(BillPayment.generate_leads_online_xml(bill_payment, bill, company_info, current_company_id, user, customer, item_service, images)) }
#    Net::FTP.open('ftp.leadsonline.com', 'tranact', 'tr@n@ct33710') do |ftp|
    Net::FTP.open('ftp.leadsonline.com', user.company.leads_online_ftp_username, user.company.leads_online_ftp_password) do |ftp|
      ftp.passive = true;
      ftp.putbinaryfile(path_to_file);
    end
    bill_payment.private_note = "Sent to Leads Online"
    bill_payment = bill_payment_service.update(bill_payment)
  end
  
end