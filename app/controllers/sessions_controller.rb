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
    user = User.authenticate(params[:username], params[:password])
    if user
#      if user.user_signed_in? # User already signed in, so create new :auth_token
#        user.generate_token(:auth_token)
#        user.save
#      end
      log_in user
#      session[:user_id] = user.id # Store user.id as a session variable.
#      user.update_token
#      cookies[:auth_token] = user.access_token.token_string # Store auth_token in a temporary cookie.
      flash[:success] = "You have been logged in."
      redirect_to root_path
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
