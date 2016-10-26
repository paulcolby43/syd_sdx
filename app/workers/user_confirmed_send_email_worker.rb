class NewUserRegistrationWorker
  include Sidekiq::Worker
  
  def perform(user_id)
    user = User.find(user_id)
    UserMailer.after_confirmation_info(user).deliver
  end
end