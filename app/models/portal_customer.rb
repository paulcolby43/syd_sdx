class PortalCustomer < ActiveRecord::Base
  
  belongs_to :user
  
#  validates_presence_of :user_id
#  validates_presence_of :customer_guid
  
  #############################
  #     Instance Methods      #
  ############################
  
  def customer
    
  end
  
  #############################
  #     Class Methods      #
  #############################
end
