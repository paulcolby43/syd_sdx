class SessionsController < ApplicationController

  def index
  end

  def new
    unless params[:account].blank?
      account_number = params[:account]
      @company = Company.find_by(account_number: account_number)
    end
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
    if params[:time_zone].blank?
      session[:time_zone] = 'America/New_York'
    else
      session[:time_zone] = params[:time_zone]
    end
    if user
      cookies.permanent[:dragon_account_number] = user.dragon_account_number # Store Dragon account number in a permanent cookie so can remember next time.
      if user.customer?
        yard_id = user.yard_id
        yard = Yard.find_by_id(user.token, yard_id)
        session[:yard_id] = yard_id
        session[:yard_name] = yard['Name']
      end
      if user.email_confirmed
        log_in user
        
        ### Trackable Information###
        sign_in_count = user.sign_in_count + 1
        last_sign_in_at = user.current_sign_in_at 
        current_sign_in_at = Time.now
        last_sign_in_ip = user.current_sign_in_ip
        current_sign_in_ip = request.remote_ip
        user.update_attributes(sign_in_count: sign_in_count, last_sign_in_at: last_sign_in_at, current_sign_in_at: current_sign_in_at, last_sign_in_ip: last_sign_in_ip, current_sign_in_ip: current_sign_in_ip)
        ### Trackable Information###
        
        unless (user.admin? and user.user_setting.currency_id.blank?) or (user.customer? and params[:customer_needs_to_change_password] == 'true')
          flash[:success] = "You have been logged in."
          unless user.customer?
            if user.admin?
              redirect_to root_path
            elsif user.mobile_dispatch?
              redirect_to trips_path
            elsif user.mobile_greeter?
              redirect_to customers_path
            elsif user.mobile_buyer?
              redirect_to customers_path
            else
              redirect_to root_path
            end
          else
#            redirect_to reports_path
#            redirect_to tickets_reports_path
            redirect_to root_path
          end
        else
          if user.admin?
            flash[:danger] = "Please verify your settings before proceeding."
            redirect_to edit_user_setting_path(user.user_setting)
          elsif user.customer?
            flash[:danger] = "Please update your password before proceeding."
            redirect_to edit_user_path(user, customer_needs_to_change_password: true)
          else
            flash[:success] = "You have been logged in."
            redirect_to root_path
          end
        end
      else
        flash.now[:danger] = 'Please activate your account by following the 
        instructions in the account confirmation email you received to proceed'
        render 'new'
      end
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
