module SessionsHelper
  
  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
    user.update_token
    session[:auth_token]= user.access_token.token_string
#    cookies[:auth_token] = { value: user.access_token.token_string, expires: 24.hours.from_now } # Store auth_token in a temporary cookie for 24 hours.
  end

  # Returns the current logged-in user (if any).
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end
  
  def log_out
    session.delete(:user_id)
    session.delete(:auth_token)
    cookies.delete(:yard_id)
    @current_user = nil
  end
  
end
