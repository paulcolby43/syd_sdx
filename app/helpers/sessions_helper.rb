module SessionsHelper
  
  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
#    session[:auth_token]= user.access_token.token_string
    user_yards = Yard.all(current_user.token)
    unless user_yards.count > 1
      # Set current yard if user only has one yard
      cookies[:yard_id] = user_yards.first['Id']
      cookies[:yard_name] = user_yards.first['Name']
    end
#    if user.customer?
#      cookies[:yard_id] = user.yard_id
#    end
#    unless user.customer?
##      user.update_token 
#      session[:auth_token]= user.access_token.token_string
#    else
#      @current_yard_id = nil
#    end
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
    @current_user = nil
#    session.delete(:auth_token)
    cookies.delete(:yard_id)
    cookies.delete(:yard_name)
    @current_yard_id = nil
    @current_yard_name = nil
  end
  
  def login_required
    unless logged_in?
      store_target_location
      flash[:danger] = "You must first log in or sign up before accessing this page."
      redirect_to root_path
    else
      session[:user_id] = current_user.id
    end
  end
  
  private

  def store_target_location
    session[:return_to] = request.url
  end
  
end
