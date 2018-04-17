class UserSetting < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :device_group
  
  validates :currency_id, presence: true, on: :update
  
  
  #############################
  #     Instance Methods      #
  ############################
  
  def images?
    table_name == "images"
  end
  
  def shipments
    table_name == "shipments"
  end
  
  ### Devices ###
  def devices
    unless not DeviceGroup.table_exists? or device_group.blank?
      device_group.devices
    else
      []
    end
  end
  
  def scale_devices
#    unless not DeviceGroup.table_exists? or device_group.blank?
#      device_group.scale_devices
#    else
#      []
#    end
    []
  end
  
  def camera_devices
    unless not DeviceGroup.table_exists? or device_group.blank?
      device_group.camera_devices
    else
      []
    end
  end
  
  def license_reader_devices
    unless not DeviceGroup.table_exists? or device_group.blank?
      device_group.license_reader_devices
    else
      []
    end
  end
  
  def license_imager_devices
    unless not DeviceGroup.table_exists? or device_group.blank?
      device_group.license_imager_devices
    else
      []
    end
  end
  
  def finger_print_reader_devices
    unless not DeviceGroup.table_exists? or device_group.blank?
      device_group.finger_print_reader_devices
    else
      []
    end
  end
  
  def signature_pad_devices
    unless not DeviceGroup.table_exists? or device_group.blank?
      device_group.signature_pad_devices
    else
      []
    end
  end
  
  def printer_devices
    unless not DeviceGroup.table_exists? or device_group.blank?
      device_group.printer_devices
    else
      []
    end
  end
  
  def customer_camera
    unless not DeviceGroup.table_exists? or device_group.blank?
      device_group.customer_camera
    else
      nil
    end
  end
  
  def scanner_devices
    unless not DeviceGroup.table_exists? or device_group.blank?
      device_group.scanner_devices
    else
      []
    end
  end
  ### End Devices ###
  
  #############################
  #     Class Methods      #
  #############################
end
