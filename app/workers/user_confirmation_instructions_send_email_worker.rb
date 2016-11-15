class UserConfirmationInstructionsSendEmailWorker
  include Sidekiq::Worker
  
  def perform(user_id)
    user = User.find(user_id)
    UserMailer.confirmation_instructions(user).deliver
  end
end