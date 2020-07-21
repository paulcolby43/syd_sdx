class AccessTokensController < InheritedResources::Base
  before_filter :login_required
  before_action :set_access_token, only: [:update]
  
  # GET /access_tokens/1/update_role
  def update_role
    if current_user.dragon_admin?
      @access_token = AccessToken.find(params[:id])
      unless params[:role].blank?
        @access_token.roles = [params[:role]]
      end
    end
    redirect_to :back
  end

  # PATCH/PUT /access_tokens/1
  # PATCH/PUT /access_tokens/1.json
  def update
    respond_to do |format|
      if @access_token.update(access_token_params)
        format.html { 
          flash[:success] = 'Access token was successfully updated.'
#          redirect_to @access_token
          redirect_to root_path
        }
        format.json { render :show, status: :ok, location: @access_token }
      else
        format.html { 
          flash.now[:danger] = 'Error updating Event.'
          render :edit 
          }
        format.json { render json: @access_token.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  private
  
    def set_access_token
      @access_token = AccessToken.find(params[:id])
    end

    def access_token_params
      params.require(:access_token).permit(roles: [])
    end
end

