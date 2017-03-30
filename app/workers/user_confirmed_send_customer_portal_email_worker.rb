class UserConfirmedSendCustomerPortalEmailWorker
  include Sidekiq::Worker
  
  def perform(user_id)
    user = User.find(user_id)
    UserMailer.after_confirmation_customer_portal_info(user).deliver
  end
end