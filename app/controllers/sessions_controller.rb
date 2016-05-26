class SessionsController < ApplicationController

  def index
  end

  def new
  end

#  def create
#    token = Token.authenticate(params[:username], params[:password])
#    if token
#      session[:access_token] = token
#      redirect_to root_url, :notice => "Logged in!"
#    else
#      flash.now.alert = "Invalid username or password"
#      render "new"
#    end
#  end
  
  def create
    user = User.authenticate(params[:username], params[:password], params[:dragon_account_number])
    if user
#      if user.user_signed_in? # User already signed in, so create new :auth_token
#        user.generate_token(:auth_token)
#        user.save
#      end
      cookies.permanent[:dragon_account_number] = user.dragon_account_number # Store Dragon account number in a permanent cookie so can remember next time.
      if user.email_confirmed
        log_in user
        flash[:success] = "You have been logged in."
        redirect_to root_path
      else
        flash.now[:danger] = 'Please activate your account by following the 
        instructions in the account confirmation email you received to proceed'
        render 'new'
      end
#      session[:user_id] = user.id # Store user.id as a session variable.
#      user.update_token
#      cookies[:auth_token] = user.access_token.token_string # Store auth_token in a temporary cookie.
    else
      flash.now[:danger] = "Invalid username or password."
      render 'new' 
    end
  end

  def destroy
    log_out
    flash[:success] = "Logged out!"
    redirect_to root_url
  end

end
