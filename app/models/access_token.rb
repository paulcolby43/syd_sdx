class AccessToken < ActiveRecord::Base
  
  belongs_to :user
  
  ############################
  #     Instance Methods     #
  ############################
  
  def expired?
    expiration < Time.now
  end
  
  #############################
  #     Class Methods         #
  #############################
end