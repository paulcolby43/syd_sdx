class PortalCustomer < ActiveRecord::Base
  
  belongs_to :user
  
#  validates_presence_of :user_id
#  validates_presence_of :customer_guid
  
  #############################
  #     Instance Methods      #
  ############################
  
  def customer(auth_token, yard_id)
    return Customer.find_by_id(auth_token, yard_id, customer_guid)
  end
  
  def name
    unless customer['LastName'].blank? and  customer['FirstName'].blank?
      "#{customer['FirstName']} #{customer['LastName']}"
    else
      customer['Company']
    end
  end
  
  #############################
  #     Class Methods      #
  #############################
end
