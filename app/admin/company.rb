ActiveAdmin.register Company do

  
  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
   permit_params :name, :dragon_api, :account_number, :include_leads_online, 
     :include_shipments, :include_inventories, :include_external_users, :jpegger_service_ip, :jpegger_service_port,
     :include_dispatch
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end
  
end
