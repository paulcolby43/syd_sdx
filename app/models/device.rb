class Device < ActiveRecord::Base
  
  establish_connection :tud_config
  
  self.primary_key = 'DevID'
  self.table_name = 'Device'
  
  belongs_to :company, foreign_key: "CompanyID"
  belongs_to :workstation, foreign_key: "WorkstationID"
#  has_many :device_group_members
  
  #############################
  #     Instance Methods      #
  ############################
  
  def scale_read
    xml_string = "<?xml version='1.0' encoding='UTF-8'?>
      <SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:ns1='urn:TUDIntf' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
         <SOAP-ENV:Body>
            <mns:ReadScale xmlns:mns='urn:TUDIntf-ITUD' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
               <WorkstationIP xsi:type='xs:string'>#{ENV['PROXY_IP']}</WorkstationIP>
               <WorkstationPort xsi:type='xs:int'>#{self.LocalListenPort}</WorkstationPort>
               <ConsecReads xsi:type='xs:int'>5</ConsecReads>
            </mns:ReadScale>
         </SOAP-ENV:Body>
      </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['TUD_WSDL_URL'])
    response = client.call(:read_scale, xml: xml_string)
    data = response.to_hash
    return data[:read_scale_response][:return]
  end
  
  def scale_camera_trigger(ticket_number, event_code, commodity_name, yard_id, weight, customer_number, vin_number, tag_number)
    xml_string = "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <SOAP-ENV:Body>
         <mns:JpeggerTrigger xmlns:mns='urn:JpeggerTriggerIntf-IJpeggerTrigger' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <Host xsi:type='xs:string'>127.0.0.1</Host>
            <Port xsi:type='xs:int'>3333</Port>
            <Trigger xsi:type='xs:string'>
               <CAPTURE>
                  <TICKET_NBR>#{ticket_number}</TICKET_NBR>
                  <EVENT_CODE>#{event_code}</EVENT_CODE>
                  <CMDY_NAME>#{commodity_name}</CMDY_NAME>
                  <CAMERA_NAME>#{self.DeviceName}</CAMERA_NAME>
                  <WEIGHT>#{weight}</WEIGHT>
                  <YARDID>#{yard_id}</YARDID>
                  <CUST_NBR>#{customer_number}</CUST_NBR>
                  <VIN>#{vin_number}</VIN>
                  <TagNbr>#{tag_number}</TagNbr>
               </CAPTURE>
            </Trigger>
         </mns:JpeggerTrigger>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['JPEGGER_WSDL_URL'])
#    Rails.logger.info xml_string
    client.call(:jpegger_trigger, xml: xml_string)
  end
  
  def drivers_license_scan
    xml_string = "<?xml version='1.0' encoding='UTF-8'?>
      <SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:ns1='urn:TUDIntf' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
         <SOAP-ENV:Body>
            <mns:ReadID xmlns:mns='urn:TUDIntf-ITUD' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
               <WorkstationIP xsi:type='xs:string'>#{ENV['PROXY_IP']}</WorkstationIP>
               <WorkstationPort xsi:type='xs:int'>#{self.LocalListenPort}</WorkstationPort>
               <Fields xsi:type='soapenc:Array' soapenc:arrayType='ns1:TTUDField[2]'>
                  <item xsi:type='ns1:TTUDField'>
                     <FieldName xsi:type='xs:string' />
                     <FieldValue xsi:type='xs:string' />
                  </item>
                  <item xsi:type='ns1:TTUDField'>
                     <FieldName xsi:type='xs:string' />
                     <FieldValue xsi:type='xs:string' />
                  </item>
               </Fields>
            </mns:ReadID>
         </SOAP-ENV:Body>
      </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['TUD_WSDL_URL'])
    response = client.call(:read_id, xml: xml_string)
    data = response.to_hash
    return Hash.from_xml(data[:read_id_response][:return])["response"]
  end
  
  def drivers_license_camera_trigger(customer_first_name, customer_last_name, customer_number, license_number, license_expiration_date, event_code, yard_id, address1, city, state, zip)
    xml_string = "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <SOAP-ENV:Body>
         <mns:JpeggerTrigger xmlns:mns='urn:JpeggerTriggerIntf-IJpeggerTrigger' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <Host xsi:type='xs:string'>127.0.0.1</Host>
            <Port xsi:type='xs:int'>3333</Port>
            <Trigger xsi:type='xs:string'>
               <CAPTURE>
                  <TABLE>cust_pics</TABLE>
                  <CAMERA_NAME>#{self.DeviceName}</CAMERA_NAME>
                  <FIRST_NAME>#{customer_first_name}</FIRST_NAME>
                  <LAST_NAME>#{customer_last_name}</LAST_NAME>
                  <CUST_NBR>#{customer_number}</CUST_NBR>
                  <ID>#{license_number}</ID>
                  <EXPIRATION_DATE>#{license_expiration_date}</EXPIRATION_DATE>
                  <EVENT_CODE>#{event_code}</EVENT_CODE>
                  <YARDID>#{yard_id}</YARDID>
                  <ADDRESS1>#{address1}</ADDRESS1>
                  <CITY>#{city}</CITY>
                  <STATE>#{state}</STATE>
                  <ZIP>#{zip}</ZIP>
               </CAPTURE>
            </Trigger>
         </mns:JpeggerTrigger>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['JPEGGER_WSDL_URL'])
    client.call(:jpegger_trigger, xml: xml_string)
  end
  
  def customer_camera_trigger(customer_number, customer_first_name, customer_last_name, event_code, yard_id)
    xml_string = "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <SOAP-ENV:Body>
         <mns:JpeggerTrigger xmlns:mns='urn:JpeggerTriggerIntf-IJpeggerTrigger' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <Host xsi:type='xs:string'>127.0.0.1</Host>
            <Port xsi:type='xs:int'>3333</Port>
            <Trigger xsi:type='xs:string'>
               <CAPTURE>
                  <TABLE>cust_pics</TABLE>
                  <CAMERA_NAME>#{self.DeviceName}</CAMERA_NAME>
                  <CUST_NBR>#{customer_number}</CUST_NBR>
                  <FIRST_NAME>#{customer_first_name}</FIRST_NAME>
                  <LAST_NAME>#{customer_last_name}</LAST_NAME>
                  <EVENT_CODE>#{event_code}</EVENT_CODE>
                  <YARDID>#{yard_id}</YARDID>
               </CAPTURE>
            </Trigger>
         </mns:JpeggerTrigger>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['JPEGGER_WSDL_URL'])
    client.call(:jpegger_trigger, xml: xml_string)
  end
  
  def drivers_license_scanned_image
    require 'open-uri'
#    open('http://192.168.111.150:10001').read
#    open("http://#{workstation.Host}:#{self.TUDPort}/jpeg.jpg").read
    
    # Show image by going direct to device
#    if eseek_imager?
#      open("http://192.168.111.150:#{self.TUDPort}/jpeg.jpg").read
#    elsif scanshell?
#      open("http://192.168.111.150:#{self.TUDPort}").read 
#    end
#    
    # Show image via proxy
    if eseek_imager?
      open("http://#{ENV['PROXY_IP']}:#{self.LocalListenPort}/jpeg.jpg").read
    elsif scanshell?
      open("http://#{ENV['PROXY_IP']}:#{self.LocalListenPort}").read 
    end
  end
  
  def get_signature(ticket_number, yard_id, customer_name, customer_number)
    xml_string = "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <SOAP-ENV:Body>
         <mns:JpeggerTrigger xmlns:mns='urn:JpeggerTriggerIntf-IJpeggerTrigger' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <Host xsi:type='xs:string'>127.0.0.1</Host>
            <Port xsi:type='xs:int'>3333</Port>
            <Trigger xsi:type='xs:string'>
               <CAPTURE>
                  <TICKET_NBR>#{ticket_number}</TICKET_NBR>
                  <EVENT_CODE>SIGNATURE CAPTURE</EVENT_CODE>
                  <CAMERA_NAME>#{self.DeviceName}</CAMERA_NAME>
                  <YARDID>#{yard_id}</YARDID>
                  <SIG_ID>#{yard_id}</SIG_ID>
                  <CONTRACT_ID>#{yard_id}</CONTRACT_ID>
                  <CUST_NAME>#{customer_name}</CUST_NAME>
                  <CUST_NBR>#{customer_number}</CUST_NBR>
               </CAPTURE>
            </Trigger>
         </mns:JpeggerTrigger>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['JPEGGER_WSDL_URL'])
    client.call(:jpegger_trigger, xml: xml_string)
  end
  
  def finger_print_trigger(ticket_number, yard_id, customer_name, customer_number)
    xml_string = "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <SOAP-ENV:Body>
         <mns:JpeggerTrigger xmlns:mns='urn:JpeggerTriggerIntf-IJpeggerTrigger' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <Host xsi:type='xs:string'>127.0.0.1</Host>
            <Port xsi:type='xs:int'>3333</Port>
            <Trigger xsi:type='xs:string'>
               <CAPTURE>
                  <TICKET_NBR>#{ticket_number}</TICKET_NBR>
                  <EVENT_CODE>Finger Print</EVENT_CODE>
                  <CAMERA_NAME>#{self.DeviceName}</CAMERA_NAME>
                  <CUST_NAME>#{customer_name}</CUST_NAME>
                  <YARDID>#{yard_id}</YARDID>
                  <CUST_NBR>#{customer_number}</CUST_NBR>
               </CAPTURE>
            </Trigger>
         </mns:JpeggerTrigger>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['JPEGGER_WSDL_URL'])
    client.call(:jpegger_trigger, xml: xml_string)
  end
  
  def call_printer_for_purchase_order_pdf(pdf_binary)
    xml_string = "<?xml version='1.0' encoding='UTF-8'?>
      <SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:ns1='urn:TUDIntf' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
         <SOAP-ENV:Body xmlns:NS1='urn:TUDIntf-ITUD' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <NS1:PrintPDF>
               <WorkstationIP xsi:type='xs:string'>#{ENV['PROXY_IP']}</WorkstationIP>
               <WorkstationPort xsi:type='xs:int'>#{self.LocalListenPort}</WorkstationPort>
               <PDFFile xsi:type='xsd:base64Binary'>#{pdf_binary}</PDFFile>
            </NS1:PrintPDF>
         </SOAP-ENV:Body>
      </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['TUD_WSDL_URL'])
    client.call(:print_pdf, xml: xml_string)
  end
  
  def call_printer_for_bill_pdf(pdf_binary)
    xml_string = "<?xml version='1.0' encoding='UTF-8'?>
      <SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:ns1='urn:TUDIntf' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
         <SOAP-ENV:Body xmlns:NS1='urn:TUDIntf-ITUD' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <NS1:PrintPDF>
               <WorkstationIP xsi:type='xs:string'>#{ENV['PROXY_IP']}</WorkstationIP>
               <WorkstationPort xsi:type='xs:int'>#{self.LocalListenPort}</WorkstationPort>
               <PDFFile xsi:type='xsd:base64Binary'>#{pdf_binary}</PDFFile>
            </NS1:PrintPDF>
         </SOAP-ENV:Body>
      </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['TUD_WSDL_URL'])
    client.call(:print_pdf, xml: xml_string)
  end
  
  def call_printer_for_bill_payment_pdf(pdf_binary)
    xml_string = "<?xml version='1.0' encoding='UTF-8'?>
      <SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:ns1='urn:TUDIntf' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
         <SOAP-ENV:Body xmlns:NS1='urn:TUDIntf-ITUD' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <NS1:PrintPDF>
               <WorkstationIP xsi:type='xs:string'>#{ENV['PROXY_IP']}</WorkstationIP>
               <WorkstationPort xsi:type='xs:int'>#{self.LocalListenPort}</WorkstationPort>
               <PDFFile xsi:type='xsd:base64Binary'>#{pdf_binary}</PDFFile>
            </NS1:PrintPDF>
         </SOAP-ENV:Body>
      </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['TUD_WSDL_URL'])
    client.call(:print_pdf, xml: xml_string)
  end
  
  def scanner_trigger(ticket_number, event_code, yard_id, customer_number, vin_number, tag_number)
    xml_string = "<?xml version='1.0' encoding='UTF-8'?>
      <SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:ns1='urn:TUDIntf' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
         <SOAP-ENV:Body>
            <mns:JpeggerTrigger xmlns:mns='urn:JpeggerTriggerIntf-IJpeggerTrigger' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
               <Host xsi:type='xs:string'>127.0.0.1</Host>
               <Port xsi:type='xs:int'>3333</Port>
               <Trigger xsi:type='xs:string'>
                <CAPTURE>
                   <TICKET_NBR>#{ticket_number}</TICKET_NBR>
                   <EVENT_CODE>#{event_code}</EVENT_CODE>
                   <CAMERA_NAME>#{self.DeviceName}</CAMERA_NAME>
                   <YARDID>#{yard_id}</YARDID>
                   <CUST_NBR>#{customer_number}</CUST_NBR>
                   <VIN>#{vin_number}</VIN>
                   <TagNbr>#{tag_number}</TagNbr>
                </CAPTURE>
               </Trigger>
            </mns:JpeggerTrigger>
         </SOAP-ENV:Body>
      </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['JPEGGER_WSDL_URL'])
    client.call(:jpegger_trigger, xml: xml_string)
  end
  
  # Serial scale
  def scale?
    self.DeviceType == 21
  end
  
  def scale_camera_only?
    scale? and self.NoHardware == 1
  end
  
  def camera?
    self.DeviceType == 5
  end
  
  def signature_pad?
    topaz_signature_pad? or equinox_direct? or wacom_signature_pad?
  end
  
  # Topaz signature pad
  def topaz_signature_pad?
    self.DeviceType == 11
  end
  
  # Equinox signature pad
  def equinox_direct?
    self.DeviceType == 16
  end
  
  # Wacom signature pad
  def wacom_signature_pad?
    self.DeviceType == 22
  end
  
  def printer?
    self.DeviceType == 20
  end
  
  def finger_print_reader?
    crossmatch? or hamster?
  end
  
  # Fingerprint scanner
  def crossmatch? 
    self.DeviceType == 12
  end
  
  # Fingerprint scanner
  def hamster? 
    self.DeviceType == 23
  end
  
  def license_reader?
    scanshell? or eseek_reader?
  end
  
  # Scanshell license/OCR capture
  def scanshell? 
    self.DeviceType == 5
  end
  
  # E-Seek Magstripe/2D Barcode reader
  def eseek_reader? 
    self.DeviceType == 6
  end
  
  def license_imager?
    scanshell? or eseek_imager?
  end
  
  # ESeek M280 Imager
  def eseek_imager?
    self.DeviceType == 17
  end
  
  def scanner?
    self.DeviceType == 18
  end
  
  def device_type_icon
    if scale?
      unless scale_camera_only?
        "<i class='fa fa-dashboard fa-lg'></i>"
      else
        "<i class='fa fa-camera fa-lg'></i>"
      end
    elsif license_reader?
      "<i class='fa fa-list-alt fa-lg'></i>"
    elsif license_imager?
      "<i class='fa fa-user fa-lg'></i>"
    elsif camera?
      "<i class='fa fa-camera fa-lg'></i>"
    elsif signature_pad?
      "<i class='fa fa-pencil fa-lg'></i>"
    elsif printer?
      "<i class='fa fa-print fa-lg'></i>"
    elsif finger_print_reader?
      "<i class='fa fa-hand-pointer-o fa-lg'></i>"
    elsif scanner?
      "<i class='fa fa-newspaper-o fa-lg'></i>"
    else
      ""
    end
  end
  
  def type
    if scale? 
      "Scale"
    elsif scanshell? 
      "Scanshell license/OCR capture"
    elsif eseek_reader? 
      "E-Seek Magstripe/2D Barcode reader"
    elsif eseek_imager?
      "ESeek M280 Imager"
    elsif camera?
      "Camera"
    elsif signature_pad?
      if topaz_signature_pad?
        "Topaz Signature Pad"
      elsif equinox_direct?
        "Equinox (direct)"
      elsif wacom_signature_pad?
        "Wacom Signature Pad"
      else
        "Signature Pad"
      end
    elsif printer?
      "PDF Printer"
    elsif finger_print_reader?
      if crossmatch?
        "Crossmatch USB"
      elsif hamster?
        "Hamster Fingerprint Reader"
      else
        "Fingerprint Reader"
      end
    elsif scanner?
      "Scanner"
    else
      "Unknown"
    end
  end
  
  def device_group_members
    DeviceGroupMember.where(DevID: id)
  end
  
  def device_groups
    device_group_members.map{|dgm| dgm.device_group }
  end
  
  def device_group_member_order(device_group_id)
    device_group_member = DeviceGroupMember.find_by_DeviceGroupID_and_DevID(device_group_id, id)
    unless device_group_member.blank?
      device_group_member.DevOrder
    else
      nil
    end
  end
  
  #############################
  #     Class Methods      #
  #############################
  
  def self.customer_camera_trigger(customer_number, customer_first_name, customer_last_name, event_code, location, camera_name, vin_number, tag_number)
    xml_string = "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <SOAP-ENV:Body>
         <mns:JpeggerTrigger xmlns:mns='urn:JpeggerTriggerIntf-IJpeggerTrigger' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <Host xsi:type='xs:string'>127.0.0.1</Host>
            <Port xsi:type='xs:int'>3333</Port>
            <Trigger xsi:type='xs:string'>
               <CAPTURE>
                  <TABLE>cust_pics</TABLE>
                  <CAMERA_NAME>#{camera_name}</CAMERA_NAME>
                  <CUST_NBR>#{customer_number}</CUST_NBR>
                  <FIRST_NAME>#{customer_first_name}</FIRST_NAME>
                  <LAST_NAME>#{customer_last_name}</LAST_NAME>
                  <EVENT_CODE>#{event_code}</EVENT_CODE>
                  <LOCATION>#{location}</LOCATION>
                  <VIN>#{vin_number}</VIN>
                  <TagNbr>#{tag_number}</TagNbr>
               </CAPTURE>
            </Trigger>
         </mns:JpeggerTrigger>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['JPEGGER_WSDL_URL'])
    client.call(:jpegger_trigger, xml: xml_string)
  end
  
  def self.customer_scanner_trigger(customer_number, customer_first_name, customer_last_name, event_code, yard_id, camera_name, vin_number, tag_number)
    xml_string = "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <SOAP-ENV:Body>
         <mns:JpeggerTrigger xmlns:mns='urn:JpeggerTriggerIntf-IJpeggerTrigger' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <Host xsi:type='xs:string'>127.0.0.1</Host>
            <Port xsi:type='xs:int'>3333</Port>
            <Trigger xsi:type='xs:string'>
               <CAPTURE>
                  <TABLE>cust_pics</TABLE>
                  <CAMERA_NAME>#{camera_name}</CAMERA_NAME>
                  <CUST_NBR>#{customer_number}</CUST_NBR>
                  <FIRST_NAME>#{customer_first_name}</FIRST_NAME>
                  <LAST_NAME>#{customer_last_name}</LAST_NAME>
                  <EVENT_CODE>#{event_code}</EVENT_CODE>
                  <YARDID>#{yard_id}</YARDID>
                  <VIN>#{vin_number}</VIN>
                  <TagNbr>#{tag_number}</TagNbr>
               </CAPTURE>
            </Trigger>
         </mns:JpeggerTrigger>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['JPEGGER_WSDL_URL'])
    client.call(:jpegger_trigger, xml: xml_string)
  end
  
  def self.customer_scale_camera_trigger(customer_number, customer_first_name, customer_last_name, event_code, yard_id, camera_name, vin_number, tag_number)
    xml_string = "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <SOAP-ENV:Body>
         <mns:JpeggerTrigger xmlns:mns='urn:JpeggerTriggerIntf-IJpeggerTrigger' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <Host xsi:type='xs:string'>127.0.0.1</Host>
            <Port xsi:type='xs:int'>3333</Port>
            <Trigger xsi:type='xs:string'>
               <CAPTURE>
                  <TABLE>cust_pics</TABLE>
                  <CAMERA_NAME>#{camera_name}</CAMERA_NAME>
                  <CUST_NBR>#{customer_number}</CUST_NBR>
                  <FIRST_NAME>#{customer_first_name}</FIRST_NAME>
                  <LAST_NAME>#{customer_last_name}</LAST_NAME>
                  <EVENT_CODE>#{event_code}</EVENT_CODE>
                  <YARDID>#{yard_id}</YARDID>
                  <VIN>#{vin_number}</VIN>
                  <TagNbr>#{tag_number}</TagNbr>
               </CAPTURE>
            </Trigger>
         </mns:JpeggerTrigger>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['JPEGGER_WSDL_URL'])
    client.call(:jpegger_trigger, xml: xml_string)
  end
  
  def self.customer_camera_trigger_from_ticket(ticket_number, event_code, yard_id, customer_number, camera_name, vin_number, tag_number)
    xml_string = "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <SOAP-ENV:Body>
         <mns:JpeggerTrigger xmlns:mns='urn:JpeggerTriggerIntf-IJpeggerTrigger' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <Host xsi:type='xs:string'>127.0.0.1</Host>
            <Port xsi:type='xs:int'>3333</Port>
            <Trigger xsi:type='xs:string'>
               <CAPTURE>
                  <TICKET_NBR>#{ticket_number}</TICKET_NBR>
                  <EVENT_CODE>#{event_code}</EVENT_CODE>
                  <CAMERA_NAME>#{camera_name}</CAMERA_NAME>
                  <YARDID>#{yard_id}</YARDID>
                  <CUST_NBR>#{customer_number}</CUST_NBR>
                  <VIN>#{vin_number}</VIN>
                  <TagNbr>#{tag_number}</TagNbr>
               </CAPTURE>
            </Trigger>
         </mns:JpeggerTrigger>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['JPEGGER_WSDL_URL'])
    client.call(:jpegger_trigger, xml: xml_string)
  end
  
  def self.drivers_license_camera_trigger_from_ticket(ticket_number, event_code, yard_id, customer_number, camera_name)
    xml_string = "<SOAP-ENV:Envelope xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:mime='http://schemas.xmlsoap.org/wsdl/mime/' xmlns:soap='http://schemas.xmlsoap.org/wsdl/soap/' xmlns:soapenc='http://schemas.xmlsoap.org/soap/encoding/' xmlns:tns='http://tempuri.org/' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
      <SOAP-ENV:Body>
         <mns:JpeggerTrigger xmlns:mns='urn:JpeggerTriggerIntf-IJpeggerTrigger' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
            <Host xsi:type='xs:string'>127.0.0.1</Host>
            <Port xsi:type='xs:int'>3333</Port>
            <Trigger xsi:type='xs:string'>
               <CAPTURE>
                  <TICKET_NBR>#{ticket_number}</TICKET_NBR>
                  <EVENT_CODE>#{event_code}</EVENT_CODE>
                  <CAMERA_NAME>#{camera_name}</CAMERA_NAME>
                  <YARDID>#{yard_id}</YARDID>
                  <CUST_NBR>#{customer_number}</CUST_NBR>
               </CAPTURE>
            </Trigger>
         </mns:JpeggerTrigger>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
    client = Savon.client(wsdl: ENV['JPEGGER_WSDL_URL'])
    client.call(:jpegger_trigger, xml: xml_string)
  end
  
end

