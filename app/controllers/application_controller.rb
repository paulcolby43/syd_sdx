class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:danger] = exception.message
    redirect_to root_url
  end
  
  private
  
#  def current_user
##    @current_user ||= User.find(session[:user_id]) if session[:user_id]
##    @current_user ||= User.find_by_auth_token( cookies[:auth_token]) if cookies[:auth_token]
#    @current_user ||= AccessToken.find_by_token_string( cookies[:auth_token]).user if cookies[:auth_token]
#  end
#  helper_method :current_user
  
#  def current_token
#    @current_token ||= session[:auth_token]
#  end
#  helper_method :current_token
  
  def current_yard_id
    @current_yard_id ||= session[:yard_id]
#    @current_yard_id ||= cookies[:yard_id]
  end
  helper_method :current_yard_id
  
  def current_yard_name
    @current_yard_name ||= session[:yard_name]
#    @current_yard_name ||= cookies[:yard_name]
  end
  helper_method :current_yard_name
  
#  def current_yard
#    @current_yard ||= Yard.find_by_id(current_token, current_yard_id)
#  end
#  helper_method :current_yard
  
  def current_ability
    @current_ability ||= Ability.new(current_user, current_yard_id)
  end
  
  ### Active Directory Token ###
  def save_in_session(auth_hash)
    # Save the token info
    session[:graph_token_hash] = auth_hash[:credentials]
    # Save the user's display name
    session[:user_name] = auth_hash.dig(:extra, :raw_info, :displayName)
    # Save the user's email address
    # Use the mail field first. If that's empty, fall back on
    # userPrincipalName
    session[:user_email] = auth_hash.dig(:extra, :raw_info, :mail) ||
                           auth_hash.dig(:extra, :raw_info, :userPrincipalName)
    # Save the user's time zone
    session[:user_timezone] = auth_hash.dig(:extra, :raw_info, :mailboxSettings, :timeZone)
  end
  
end
