class CustomerUserPortalConfirmationInstructionsSendEmailWorker
  include Sidekiq::Worker
  
  def perform(user_id)
    user = User.find(user_id)
    UserMailer.customer_user_portal_confirmation_instructions(user).deliver
  end
end