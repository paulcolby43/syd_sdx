class UserMailer < ActionMailer::Base
#  default from: "admin@jeremysenn.com"
  default from: "#{ENV['GMAIL_USERNAME']}"

  def confirmation_instructions(user)
    @user = user
    mail(:to => user.email, :subject => "Confirmation instructions")
  end
  
  def forgot_password_instructions(user)
    @user = user
    mail(:to => user.email, :subject => "Reset password")
  end
  
  def new_user_registration(user)
    @user = user
    @to = 'john@tranact.com'
    @cc = "info@tranact.com, patrick@tranact.com, ken@tranact.com, brian@tranact.com, jeremy@tranact.com, tim@tranact.com, colby@tranact.com"
    mail(to: @to, cc: @cc, subject: 'SYD SDX New User Sign Up')
  end

end
