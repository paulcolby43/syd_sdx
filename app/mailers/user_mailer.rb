class UserMailer < ActionMailer::Base
#  default from: "admin@jeremysenn.com"
  default from: "#{ENV['GMAIL_USERNAME']}"

  def confirmation_instructions(user)
    @user = user
    mail(:to => user.email, :subject => "Confirmation instructions")
  end
  
  def customer_user_portal_confirmation_instructions(user)
    @user = user
    mail(:to => user.email, :subject => "Confirm Account for the Scrap Dragon Portal")
  end
  
  def after_confirmation_info(user)
    @user = user
    mail(:to => user.email, :subject => "Dragon Dog Useful Tips")
  end
  
  def after_confirmation_customer_portal_info(user)
    @user = user
    mail(:to => user.email, :subject => "Welcome to the Scrap Dragon Customer Portal!")
  end
  
  def forgot_password_instructions(user)
    @user = user
    mail(:to => user.email, :subject => "Reset password")
  end
  
  def new_user_registration(user)
    @user = user
    @to = 'info@tranact.com'
    @cc = "patrick@tranact.com, ken@tranact.com, brian@tranact.com, jeremy@tranact.com, tim@tranact.com, colby@tranact.com, adam.greenberg@tranact.com"
    mail(to: @to, cc: @cc, subject: 'SYD SDX New User Sign Up')
  end
  
  def ticket_information(user, ticket, line_items, recipients, images_array)
    @user = user
    @ticket = ticket
    @line_items = line_items
    @to = recipients
    @images_array = images_array
    mail(to: @to, subject: "Scrap Dragon Ticket #{@ticket['TicketNumber']}")
  end

end
