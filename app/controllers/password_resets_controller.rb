class PasswordResetsController < ApplicationController
  
  def new
  end
  
  def create
    unless params[:email].blank?
      @user = User.where(email: params[:email]).first
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
    if @user.password_reset_sent_at < 2.hours.ago
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_path
    else
#      @user.reset_scrap_dragon_password(params[:user][:password]) unless params[:user].blank?
      flash[:success] = "Password has been reset."
      redirect_to login_path
#      if @user.update_attributes(params[:user])
#        redirect_to root_url, :notice => "Password has been reset."
#      else
#        render :edit
#      end
    end
  end
  
end
