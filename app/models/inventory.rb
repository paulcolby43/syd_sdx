class Inventory < ActiveRecord::Base
  
  serialize :closed_packs, Array
  serialize :scanned_packs, Array
  
  belongs_to :user
  belongs_to :company
  
  ############################
  #     Instance Methods     #
  ############################
  
  
  #############################
  #     Class Methods         #
  #############################
end