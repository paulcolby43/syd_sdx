class UserMailerController < ApplicationController

  def contact_us
    respond_to do |format|
      format.html { }
      format.js {
        from_email = params[:email]
        subject = params[:subject]
        message = params[:message]
        UserMailer.contact_us_email(from_email, subject, message).deliver_now
      }
    end
  end

end
