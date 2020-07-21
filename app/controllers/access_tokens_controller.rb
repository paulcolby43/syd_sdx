class AccessTokensController < InheritedResources::Base
  before_filter :login_required
  
  # GET /access_tokens/1/update_role
  def update_role
    if current_user.dragon_admin?
      @access_token = AccessToken.find(params[:id])
      Rails.logger.debug "********* #{params[:role]}"
      unless params[:role].blank?
        @access_token.roles = [params[:role]]
        @access_token.save
      end
    end
    redirect_to root_path
  end

  private
  
    def set_access_token
      @access_token = AccessToken.find(params[:id])
    end

    def access_token_params
      params.require(:access_token).permit(:roles)
    end
end

