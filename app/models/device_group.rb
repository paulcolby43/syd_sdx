class DeviceGroup < ActiveRecord::Base
  
  establish_connection :tud_config
  
  self.primary_key = 'DeviceGroupID'
  self.table_name = 'DeviceGroups'
  
#  belongs_to :company, foreign_key: "CompanyID"
#  has_many :device_group_members
  has_many :user_settings
  
  #############################
  #     Instance Methods      #
  ############################
  
  def device_group_members
    DeviceGroupMember.where(DeviceGroupID: id)
  end
  
  def devices
    member_devices = []
    device_group_members.sort_by{|dgm| dgm.DevOrder}.each do |dgm|
      device = Device.where(DevID: dgm.DevID).first
      member_devices << device unless device.blank?
    end
    return member_devices
#    device_group_members.sort_by{|dgm| dgm.DevOrder}.map{|dgm| dgm.device }
  end
  
  def scale_devices
    devices.select {|device| device.DeviceType == 21}
  end
  
#  def camera_devices
#    devices.select {|device| device.DeviceType == 5}
#  end

  def signature_pad_devices
    devices.select {|device| device.DeviceType == 11 or device.DeviceType == 16 or device.DeviceType == 22}
  end
  
  def printer_devices
    devices.select {|device| device.DeviceType == 20}
  end
  
  def finger_print_reader_devices
    devices.select {|device| device.DeviceType == 12 or device.DeviceType == 23}
  end
  
  def license_reader_devices
    devices.select {|device| device.DeviceType == 5 or device.DeviceType == 6}
  end
  
  def license_imager_devices
    devices.select {|device| device.DeviceType == 5 or device.DeviceType == 17}
  end
  
  def customer_camera
    self.CustomerCamera
#    camera_devices = devices.select {|device| device.DeviceName == self.CustomerCamera}
#    unless camera_devices.blank?
#      return camera_devices.first
#    else
#      nil
#    end
  end
  
  def scanner_devices
    devices.select {|device| device.DeviceType == 18}
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.table_exists?
    false
#    DeviceGroup.connection
#    rescue TinyTds::Error
#      false
#    else
#      true
  end
  
  
end

