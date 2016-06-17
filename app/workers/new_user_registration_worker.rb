class NewUserRegistrationWorker
  include Sidekiq::Worker
  
  def perform(user_id)
    user = User.find(user_id)
    UserMailer.new_user_registration(user).deliver
  end
end