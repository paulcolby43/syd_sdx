class Workstation < ActiveRecord::Base
  
  establish_connection :tud_config
  
  self.primary_key = 'WorkstationID'
  self.table_name = 'Workstation'
  
  belongs_to :company, foreign_key: "CompanyID"
  has_many :devices
  
  #############################
  #     Instance Methods      #
  ############################
  
  
  #############################
  #     Class Methods      #
  #############################
  
  def self.database_exists?
    ActiveRecord::Base.connection
    rescue ActiveRecord::NoDatabaseError
      false
    else
      true
  end
  
end

