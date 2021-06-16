class DeviceGroupMember < ActiveRecord::Base
  
  establish_connection :tud_config
  
  self.table_name = 'DeviceGroupMembers'
  
  belongs_to :device_group, foreign_key: "DeviceGroupID"
  belongs_to :device, foreign_key: "DevID"
  
  #############################
  #     Instance Methods      #
  ############################
  
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.table_exists?
    false
#    DeviceGroupMember.connection
#    rescue TinyTds::Error
#      false
#    else
#      true
  end
  
  
end

