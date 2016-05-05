class UsersController < ApplicationController
  before_filter :login_required, :except => [:new, :create, :confirm_email, :resend_confirmation_instructions]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
#  load_and_authorize_resource
#  skip_authorize_resource :only => [:new, :create, :confirm_email, :resend_confirmation_instructions]

  # GET /users
  # GET /users.json
  def index
#    @users = User.all
    @users = current_user.company.users
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        unless @user.customer?
#          @user.generate_scrap_dragon_token(user_params[:username], user_params[:password], "#{ENV['SCRAP_DRAGON_API_HOST']}:#{ENV['SCRAP_DRAGON_API_PORT']}")
          create_scrap_dragon_user_response = @user.create_scrap_dragon_user(user_params) if current_user.blank?
          create_scrap_dragon_user_response = @user.create_scrap_dragon_user_for_current_user(current_user.token, user_params) unless current_user.blank?
          @user.generate_scrap_dragon_token(user_params)
        else
          create_scrap_dragon_user_response = @user.create_scrap_dragon_customer_user(current_user.token, user_params)
          @user.generate_scrap_dragon_token(user_params)
#          @user.generate_scrap_dragon_token('9', '9', @user.company.dragon_api) # TODO: Get generic customer user for read-only access to tickets
        end
        format.html { 
          if create_scrap_dragon_user_response == 'true'
            UserMailer.confirmation_instructions(@user).deliver
            flash[:success] = "Confirmation instructions have been sent to the user email address."
          else
            flash[:danger] = "There was a problem creating the Scrap Dragon user."
          end
          redirect_to login_path if current_user.blank?
          redirect_to users_path unless current_user.blank?
#          redirect_to @user
          }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { 
          if current_user.blank?
            render :new
          else
            flash[:danger] = "There was a problem creating the Scrap Dragon user."
            redirect_to :back 
          end
          }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { 
          flash[:success] = "User was successfully updated."
          redirect_to @user
        }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def confirm_email
    user = User.find_by_confirm_token(params[:id])
    if user
      user.email_activate
      flash[:success] = "Welcome to Scrap Yard Dog! Your email has been confirmed.
      Please sign in to continue."
      redirect_to login_path
    else
      flash[:danger] = "Sorry. User does not exist"
      redirect_to root_url
    end
  end

  def resend_confirmation_instructions
    unless params[:email].blank?
      @user = User.where(email: params[:email]).first
      unless @user.blank?
        unless @user.confirm_token.blank?
          UserMailer.confirmation_instructions(@user).deliver
          flash[:success] = "The email confirmation instructions have been re-sent."
        else
          flash[:danger] = "This email address has already been confirmed."
        end
      else
        flash[:danger] = "Email address not found."
      end
      redirect_to root_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :password, :password_confirmation, :first_name, :last_name, :company_name, :email, :phone, 
        :customer_guid, :role, :yard_id, :company_id, :address1, :address2, :city, :state, :terms_of_service)
    end
end
