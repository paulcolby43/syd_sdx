class UsersController < ApplicationController
  before_filter :login_required, :except => [:new, :create, :confirm_email, :resend_confirmation_instructions]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :update_latitude_and_longitude]
  load_and_authorize_resource  param_method: :user_params, :except => [:new, :create, :confirm_email, :resend_confirmation_instructions]

  # GET /users
  # GET /users.json
  def index
#    @users = User.all
    @users = current_user.company.users
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @portal_customers = @user.portal_customers
    @dragon_roles = @user.access_token.roles unless @user.access_token.blank?
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    if @user.customer?
#      @customer_user_portal_customer = @user.customer_user_portal_customers.build
#      @portal_customers = @user.portal_customers
#      @customers = Customer.all(current_user.token, current_yard_id)
      @portal_customers_options_array = @user.portal_customers_options_array(current_user.token, current_yard_id)
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    if Company.count == 1
      # When there is only one company, all users go under that company
      @user.company_id = Company.first.id
    end
    respond_to do |format|
      unless @user.customer?
        create_scrap_dragon_user_response = User.create_scrap_dragon_user(user_params) if current_user.blank? and user_params[:dragon_account_number].blank?
        unless current_user.blank?
          create_scrap_dragon_user_response = User.create_scrap_dragon_user_for_current_user(current_user.token, user_params)
          current_valid_scrap_dragon_user_response = User.current_valid_scrap_dragon_user(current_user.token, user_params)
        end
      else
        create_scrap_dragon_user_response = User.create_scrap_dragon_customer_user(current_user.token, user_params)
      end
      format.html { 
        if create_scrap_dragon_user_response.blank? or create_scrap_dragon_user_response["Success"] == 'true' # Private Dragon API or Dragon user successfully created
          if @user.save
            generate_scrap_dragon_token_response = User.generate_scrap_dragon_token(user_params, @user.id)
            if generate_scrap_dragon_token_response == 'success'
              @user.send_confirmation_instructions_email
              flash[:success] = "New user created."
              redirect_to login_path if current_user.blank?
              redirect_to users_path unless current_user.blank?
            else
              flash[:danger] = "Problem creating user: #{generate_scrap_dragon_token_response}"
              redirect_to login_path if current_user.blank?
              redirect_to users_path unless current_user.blank?
            end
          else
            if current_user.blank?
              render :new
            else
              flash[:danger] = "There was a problem creating the user in Scrap Yard Dog: #{@user.errors.each do |attr, msg| puts '#{attr} #{msg}' end}"
              redirect_to :back 
            end
          end
        else
          if create_scrap_dragon_user_response['FailureInformation'] == 'Username already exists.'
            if current_valid_scrap_dragon_user_response == 'true'
              # This is an existing valid dragon user with correct password
              @user.email_confirmed = true # Automatically confirm email address since already in Dragon
              if @user.save
                generate_scrap_dragon_token_response = User.generate_scrap_dragon_token(user_params, @user.id)
                if generate_scrap_dragon_token_response == 'success'
                  # Save user's dragon roles
                  @user.access_token.update_attribute(:roles, @user.dragon_role_names)
                  flash[:success] = "Scrap Dragon user successfully added to Scrap Yard Dog."
                  redirect_to login_path if current_user.blank?
                  redirect_to users_path unless current_user.blank?
                else
                  flash[:danger] = "Problem adding Scrap Dragon user to Scrap Yard Dog: #{generate_scrap_dragon_token_response}"
                  @user.destroy
                  redirect_to login_path if current_user.blank?
                  redirect_to users_path unless current_user.blank?
                end
              else
                #flash[:danger] = "There was a problem creating the user in Scrap Yard Dog: #{@user.errors.each do |attr, msg| puts '#{attr} #{msg}' end}"
                render :new
              end
            else
              # current_valid_scrap_dragon_user_response did not return true, so password is incorrect for existing dragon user
              flash[:danger] = "Problem adding Scrap Dragon user to Scrap Yard Dog: username already exists, or password is incorrect."
              redirect_to login_path if current_user.blank?
              redirect_to users_path unless current_user.blank?
            end
          else
            flash[:danger] = "There was a problem creating the user in Scrap Dragon #{create_scrap_dragon_user_response}"
            redirect_to login_path if current_user.blank?
            redirect_to users_path unless current_user.blank?
          end
        end
        
        }
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @customers = Customer.all(current_user.token, current_yard_id)
    respond_to do |format|
      if user_params[:password].blank? # No update to password
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
      else # Creating new password
        reset_scrap_dragon_password_response = @user.reset_scrap_dragon_password(@user.id, user_params[:password])
        if reset_scrap_dragon_password_response["Success"] == 'true'
          if @user.update(user_params)
            format.html { 
              flash[:success] = "User was successfully updated."
#              redirect_to @user
              redirect_to root_path
            }
            format.json { render :show, status: :ok, location: @user }
          else
            format.html { render :edit }
            format.json { render json: @user.errors, status: :unprocessable_entity }
          end
        else
          flash[:danger] = "There was a problem resetting your password: #{reset_scrap_dragon_password_response["FailureInformation"]}"
          redirect_to @user
        end
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { 
        flash[:success] = 'User was successfully destroyed.'
        redirect_to users_url 
        }
      format.json { head :no_content }
    end
  end
  
  def confirm_email
    user = User.find_by_confirm_token(params[:id])
    if user
      user.email_activate
      user.send_after_confirmation_info_email
      flash[:success] = "Welcome to Scrap Yard Dog! Your email has been confirmed.
      Please sign in to continue."
      if user.customer?
        redirect_to login_path(customer_guid: user.customer_guid)
      else
        redirect_to login_path
      end
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
  
  # GET /users/1/update_latitude_and_longitude
  # GET /users/1/update_latitude_and_longitude.json
  def update_latitude_and_longitude
    respond_to do |format|
      if @user.update(latitude: params[:latitude], longitude: params[:longitude])
        format.json { head :no_content }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
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
        :customer_guid, :role, :yard_id, :company_id, :address1, :address2, :city, :state, :zip, :terms_of_service, :email_confirmed, :confirm_token, 
        :dragon_account_number, :view_images, :active, portal_customers_attributes:[:user_id, :customer_guid, :_destroy,:id])
    end
end
