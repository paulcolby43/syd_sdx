class AccessToken < ActiveRecord::Base
  
  belongs_to :user
  serialize :roles, Array # Treat roles column as an array
  
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