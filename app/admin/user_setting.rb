ActiveAdmin.register UserSetting do

  
  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
#   permit_params :active, :location
  permit_params :show_thumbnails, :table_name, :show_customer_thumbnails, :show_ticket_thumbnails, :device_group_id, :currency_id
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end
  
end
