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
      session[:user_id] = user.id # Store user.id as a session variable.
      user.update_token
      cookies[:auth_token] = user.access_token.token_string # Store auth_token in a temporary cookie.
      redirect_to root_path, :notice => "You have been logged in."
#      if params[:remember_me]
#        cookies.permanent[:auth_token] = user.auth_token # Store auth_token in a permanent cookie so can remember next time.
#      else
#        cookies[:auth_token] = user.auth_token # Store auth_token in a temporary cookie.
#      end
#        redirect_to_target_or_default home_url if mobile_device?
#        redirect_to_target_or_default '/home#index', :notice => "You have been logged in." if not mobile_device?

    else
      flash.now[:error] = "Invalid username or password."
      render :action => 'new' #if not mobile_device?
    end
  end

  def destroy
    session[:user_id] = nil
    cookies.delete(:auth_token)
    redirect_to root_url, :notice => "Logged out!"
  end

end
