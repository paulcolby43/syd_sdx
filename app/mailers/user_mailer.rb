class UserMailer < ActionMailer::Base
#  default from: "admin@jeremysenn.com"
  default from: "#{ENV['GMAIL_USERNAME']}@gmail.com"

  def confirmation_instructions(user)
    @user = user
    mail(:to => user.email, :subject => "Confirmation instructions")
  end

end
