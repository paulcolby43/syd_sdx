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
        image.yardid == yard_id
      end
      can :create, Image
      can :advance_search, :images

      # ImageFiles
      ############
      can :manage, ImageFile do |image_file|
        image_file.user_id == user.id
      end
      can :create, ImageFile

#      # Shipments
#      ############
#      can :manage, Shipment do |shipment|
#        shipment.location == user.location
#      end
#      can :create, Shipment
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
        true
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
#      
    # End admin user role
    
    elsif user.customer?
    
      # Images
      ############
      can :manage, Image do |image|
        image.cust_nbr == user.customer_guid
      end
    
    end # End customer user role
    
  end
end
