class PasswordResetsController < ApplicationController
  
  def new
  end
  
  def create
    unless params[:email].blank?
      @user = User.where(email: params[:email].downcase).first
      unless @user.blank?
        @user.send_password_reset
        flash[:success] = "Email sent with password reset instructions."
      else
        flash[:danger] = "Email address not found."
      end
      redirect_to root_path
    end
  end
  
  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end
  
  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.blank? or @user.password_reset_sent_at < 2.hours.ago
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_path
    else
      reset_scrap_dragon_password_response = @user.reset_scrap_dragon_password(@user.id, params[:user][:password]) unless params[:user].blank?
      if reset_scrap_dragon_password_response["Success"] == 'true'
        flash[:success] = "Password has been reset."
        redirect_to login_path
      else
        flash[:danger] = "There was a problem resetting your password: #{reset_scrap_dragon_password_response["FailureInformation"]}"
        redirect_to login_path
      end
    end
  end
  
end
