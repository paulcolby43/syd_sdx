class UserMailer < ActionMailer::Base
#  default from: "admin@jeremysenn.com"
  default from: "#{ENV['GMAIL_USERNAME']}@gmail.com"

  def confirmation_instructions(user)
    @user = user
    mail(:to => user.email, :subject => "Confirmation instructions")
  end
  
  def forgot_password_instructions(user)
    @user = user
    mail(:to => user.email, :subject => "Reset password")
  end

end
