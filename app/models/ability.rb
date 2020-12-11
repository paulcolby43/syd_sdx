class Ability
  include CanCan::Ability

#  def initialize(user)
  def initialize(user, yard_id=nil)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/bryanrite/cancancan/wiki/Defining-Abilities
    
    if user.admin?
      
      # Tickets
      ############
      can :index, :tickets
      can :show, :tickets
      can :edit, :tickets
      can :send_to_leads_online, :tickets
      can :void, :tickets
      
      # Customers
      ############
      can :index, :customers
      can :show, :customers
      can :create, :customers
      can :edit, :customers
      
      # Commodities
      ############
      can :index, :commodities
      can :show, :commodities
      can :create, :commodities
      can :edit, :commodities
      
      # AccountsPayables
      ############
      can :manage, AccountsPayable
      
      # CheckingAccounts
      ############
      can :manage, CheckingAccount
      
      # Yards
      ############
      can :manage, Yard
      
      # Images
      ############
      can :manage, Image do |image|
#        image.yardid == yard_id and user.view_images?
        user.view_images?
      end
      can :create, Image
      can :advance_search, :images

      # ImageFiles
      ############
      can :manage, ImageFile do |image_file|
        image_file.user_id == user.id
      end
      can :create, ImageFile
      
      # Companies
      ############
      can :manage, Company do |company|
        company.id == user.company_id
      end
      cannot :index, Company

      # Shipments
      ############
      can :manage, Shipment do |shipment|
        shipment.yardid == yard_id
      end
      can :create, Shipment
#
#      # ShipmentFiles
#      ############
#      can :manage, ShipmentFile do |shipment_file|
#        shipment_file.user_id == user.id
#      end
#      can :create, ShipmentFile

      # CustPics
      ############
      can :manage, CustPic do |cust_pic|
        cust_pic.yardid == yard_id
      end
      can :create, CustPic

      # CustPicFiles
      ############
      can :manage, CustPicFile do |cust_pic_file|
        cust_pic_file.user_id == user.id
      end
      can :create, CustPicFile
      
      # Users
      ############
      can :manage, User do |u|
        u.company_id == user.company_id
      end
      can :create, User

      # UserSettings
      ############
      can :manage, UserSetting do |user_setting|
        user_setting.user_id == user.id
      end
      can :create, UserSetting

#      # LookupDefs
#      ############
#      can :manage, LookupDef do |lookup_def|
#  #      lookup_def.user_id == user.id
#      end
#      can :create, LookupDef
#
#      # Contracts
#      ############
      can :manage, Contract do |contract|
        contract.contract_id == yard_id
      end
      can :create, Contract
#
#      # JpeggerContracts
#      ############
#      can :manage, JpeggerContract do |jpegger_contract|
#        jpegger_contract.contract_id.to_s == user.location
#      end
#      can :create, JpeggerContract
#
#      # Companies
#      ############
#      can :manage, Company do |company|
#        company.CompanyID == user.location
#      end
#      #can :create, Company
      
      # Reports
      ############
      can :index, :reports
      
      # Packs
      ############
      can :index, :packs
      can :show, :packs
      can :create, :packs
      can :edit, :packs
      can :search_by_tag_number, :packs
      can :show_information, :packs
      
      # PackLists
      ############
      can :index, :pack_lists
      can :show, :pack_lists
      can :create, :pack_lists
      can :edit, :pack_lists
      
      # PackContracts
      ############
      can :index, :pack_contracts
      can :show, :pack_contracts
      can :create, :pack_contracts
      can :edit, :pack_contracts
      
      # PackShipments
      ############
      if user.company.include_shipments?
        can :index, :pack_shipments
        can :show, :pack_shipments
        can :edit, :pack_shipments
        can :fetches, :pack_shipments
        can :pictures, :pack_shipments
      end
      
      # Inventories
      ############
      if user.company.include_inventories?
        can :manage, Inventory do |inventory|
          inventory.user_id == user.id
        end
        can :index, :inventories
        can :show, :inventories
        can :create, :inventories
        can :edit, :inventories
      end
      
      # EventCodes
      ############
      can :manage, EventCode do |event_code|
        event_code.company_id == user.company_id
      end
      can :create, EventCode
      
      # Trips
      ############
      if user.company.include_dispatch?
        can :index, :trips
        can :show, :trips
        can :create, :trips
        can :edit, :trips
        can :search, :trips
      end
      
      # Tasks
      ############
      can :show, :tasks
      can :edit, :tasks
      
      # Containers
      ############
      can :show, :containers
      can :edit, :containers
      
      # Locations
      ############
      can :show, :locations
      
      # Workorders
      ############
      can :show, :workorders
      
      # SuspectLists
      ############
      can :index, :suspect_lists
      can :show, :suspect_lists
      can :create, :suspect_lists
      can :edit, :suspect_lists
      
    # End admin user role
    
    elsif user.basic?
    # Start basic user type
     
      # Tickets
      ############
      if user.mobile_buy?
        can :index, :tickets
        can :show, :tickets
        can :edit, :tickets
        can :void, :tickets
      end
      if user.mobile_greeter? or user.mobile_inspector? or user.mobile_buy?
        can :index, :tickets
        can :edit, :tickets
      end
        
      # Customers
      ############
      if user.mobile_buy? or user.mobile_greeter?
        can :index, :customers
        can :show, :customers
        can :create, :customers
        can :edit, :customers
      end
      
      # Commodities
      ############
      if user.mobile_buy?
        can :index, :commodities
        can :show, :commodities
      end
      if user.mobile_greeter?
        can :index, :commodities
        can :show, :commodities
      end
      
      if user.mobile_sell?
        # Mobile Sell or Admin Dragon Role
        # PackShipments
        ############
        if user.company.include_shipments?
          can :index, :pack_shipments
          can :show, :pack_shipments
          can :edit, :pack_shipments
          can :fetches, :pack_shipments
          can :pictures, :pack_shipments
        end

        # Inventories
        ############
        if user.company.include_inventories?
          can :manage, Inventory do |inventory|
            inventory.user_id == user.id
          end
          can :index, :inventories
          can :show, :inventories
          can :create, :inventories
          can :edit, :inventories
        end
      end
      
      # Reports
      ############
      if user.mobile_reports? or user.mobile_buyer?
        can :index, :reports
      end
      
      if user.mobile_dispatch?
        # Mobile Dispatch or Admin Dragon Role
        # Trips
        ############
        if user.company.include_dispatch?
          can :index, :trips
          can :show, :trips
          can :edit, :trips
        end

        # Tasks
        ############
        can :show, :tasks
        can :edit, :tasks
        
        # Containers
        ############
        can :show, :containers
        can :edit, :containers
        
        # Locations
        ############
        can :show, :locations
      end
      
      # Images
      ############
      can :manage, Image do |image|
        image.yardid == yard_id and user.view_images?
      end
      can :create, Image
      can :advance_search, :images

      # ImageFiles
      ############
      can :manage, ImageFile do |image_file|
        image_file.user_id == user.id
      end
      can :create, ImageFile
      
      # CustPics
      ############
      can :manage, CustPic do |cust_pic|
        cust_pic.yardid == yard_id
      end
      can :create, CustPic

      # CustPicFiles
      ############
      can :manage, CustPicFile do |cust_pic_file|
        cust_pic_file.user_id == user.id
      end
      can :create, CustPicFile
      
      # UserSettings
      ############
      can :manage, UserSetting do |user_setting|
        user_setting.user_id == user.id
      end
      can :create, UserSetting

      # User
      ############
      can :manage, User do |user_record|
        user_record.id == user.id
      end
      cannot :index, User
    
    # End basic user role
    
    elsif user.customer?
    # Start customer user role
      # Tickets
      ############
      can :index, :tickets
      can :show, :tickets
    
      # Images
      ############
      can :manage, Image do |image|
#        image.cust_nbr == user.customer_guid and user.view_images?
        user.view_images?
      end
      
      # User
      ############
      can :manage, User do |user_record|
        user_record.id == user.id
      end
      
      # Reports
      ############
      can :index, :reports
      
      # PackShipments
      ############
      can :show, :pack_shipments
      can :pictures, :pack_shipments
      
      # Commodities
      ############
      can :customer_index, :commodities
      can :customer_show, :commodities
      
      # Workorders
      ############
      can :show, :workorders
      
    # End customer user role
    end 
    
  end
end
