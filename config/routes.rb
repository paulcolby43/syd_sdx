Rails.application.routes.draw do
  
  resources :ticket_items do
    member do
      post 'save_vin'
      post 'add'
      post 'quick_add'
    end
  end
  
  resources :tasks do
    member do
      get 'remove_container'
      get 'create_new_container'
      get 'update_container'
    end
  end
  
  resources :trips do
    collection do
      get :search
    end
  end
  
  resources :inv_tags do
    member do
      get 'show_jpeg_image'
      get 'show_preview_image'
    end
  end
  
  resources :event_codes
  
  resources :password_resets

  resources :devices do
    member do
      get :drivers_license_scan
      get :scale_read
      get :scale_camera_trigger
      get :show_scanned_jpeg_image
      get :drivers_license_camera_trigger
      get :get_signature
      get :call_printer_for_purchase_order_pdf
      get :finger_print_trigger
      get :scanner_trigger
    end
    collection do
      get :customer_camera_trigger
      get :customer_scanner_trigger
      get :customer_scale_camera_trigger
      get :customer_camera_trigger_from_ticket
      get :drivers_license_camera_trigger_from_ticket
    end
  end
  resources :workorders
  
  resources :reports do 
    collection do
      get :telerik
    end
  end
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :companies
  
  resources :contracts
  
  resources :accounts_payables
  
  resources :checking_accounts
  
  resources :cust_pics do
    member do
      get 'show_jpeg_image'
      get 'show_preview_image'
      get 'send_pdf_data'
    end
  end
  
  resources :cust_pic_files
  
  resources :user_settings
  
  resources :images do
    member do
      get 'show_jpeg_image'
      get 'show_preview_image'
      get 'send_pdf_data'
      get 'preview'
    end
    collection do
      get 'advanced_search'
    end
  end
  
  resources :shipments do
    member do
      get 'show_jpeg_image'
      get 'show_preview_image'
    end
  end
  
  resources :blobs do
    member do
      get 'show_jpeg_image'
      get 'show_preview_image'
    end
  end
  
  ### Start sidekiq stuff ###
  require 'sidekiq/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web => '/sidekiq'
  ### End sidekiq stuff ###
  
  resources :image_files
  
  resources :shipment_files
  
  resources :users do
    member do
      get :confirm_email
      get :update_latitude_and_longitude
      get :add_coordinates
    end
    collection do
      get :resend_confirmation_instructions
      get :send_forgot_password_instructions
    end
  end
  
  resources :yards
  
  resources :commodities do
    member do
      put 'update_price'
      get :price
      get :unit_of_measure_weight_conversion
      get :customer_show
    end
    collection do
      get :customer_index
      get :unit_of_measure_lb_conversion
    end
  end
  
  resources :customers do
    member do
      get 'create_ticket'
    end
    collection do
      get 'service_requests'
    end
  end
  
  resources :tickets do
    collection do
      get :line_item_fields
      get :void_item
      get :customer_tickets
      get :vin_search
    end
    member do
      get :send_to_leads_online
      get :email
    end
  end
  
  resources :packs do
    collection do
      get :search_by_tag_number
      get :show_information
    end
  end
  
  resources :pack_lists do
    collection do
      get :pack_fields
    end
    member do
      get :add_pack
      get :remove_pack
      get :add_pack_to_contract_item
    end
  end
  
  resources :pack_contracts
  
  resources :pack_shipments do
    member do
      get :fetches
      get :show_pictures
    end
  end
  
  resources :inventories do
    member do
      get :add_scanned_pack
      get :remove_scanned_pack
    end
  end
  
  resources :containers
  resources :locations
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
   root 'welcome#index'
   
  get 'welcome/privacy' => 'welcome#privacy'
  get 'welcome/tos' => 'welcome#tos'
  get 'scoreboard' => 'welcome#kpi_dashboard'
   
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'
  get 'signup' => 'users#new'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  
  resources :sessions
  
end
