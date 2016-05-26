ActiveAdmin.register User do

  
  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
#   permit_params :active, :location
   permit_params :username, :password, :password_confirmation, :first_name, :last_name, :company_name, :email, :phone, 
        :customer_guid, :role, :yard_id, :company_id, :address1, :address2, :city, :state, :terms_of_service, :email_confirmed, :confirm_token, :dragon_account_number
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end
  
end
