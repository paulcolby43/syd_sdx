# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Picture Uploads ###
  $("#new_cust_pic_file").fileupload
    dataType: "script"
    disableImageResize: false
    imageMaxWidth: 1024
    imageMaxHeight: 768
    imageMinWidth: 800
    imageMinHeight: 600
    imageCrop: false

    add: (e, data) ->
      file = undefined
      types = undefined
      types = /(\.|\/)(gif|jpe?g|png|pdf)$/i
      file = data.files[0]
      if types.test(file.type) or types.test(file.name)
        data.context = $(tmpl("template-upload", file))
        current_data = $(this)
        data.process(->
          current_data.fileupload 'process', data
        ).done ->
          data.submit()
        $('#pictures').prepend('<div class="row"><div class="col-xs-12 col-sm-4 col-md-4 col-lg-4"><div class="thumbnail"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
        $('#cust_pics').prepend('<div class="row"><div class="col-xs-12 col-sm-2 col-md-2 col-lg-2"><div class="thumbnail"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
        $(".picture_loading_spinner").show()
      else
        alert "" + file.name + " is not a gif, jpeg, or png picture file"

    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.progress-bar').css('width', progress + '%')

  ### Start endless page stuff ###
  loading_customers = false
  $('a.load-more-customers').on 'inview', (e, visible) ->
    return if loading_customers or not visible
    loading_customers = true
    if not $('a.load-more-customers').is(':hidden')
      $('#more_customers_spinner').show()
    $('a.load-more-customers').hide()

    $.getScript $(this).attr('href'), ->
      loading_customers = false
  ### End endless page stuff ###

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.customer_button').each ->
      $.rails.enableElement $(this)
      return
    return

  ### Event code changed - check if Vehicle ###
  $('#cust_pic_file_event_code').on 'change', ->
    input_select = $(this)
    if input_select.val() == 'Vehicle'
      $('#tag_form_group').show()
      $('#vin_form_group').show()
    else
      $('#tag_form_group').hide()
      $('#cust_pic_file_tag_number').val ''
      $('#vin_form_group').hide()
      $('#cust_pic_file_vin_number').val ''
    return
  ### End event code changed - check if Vehicle ###

  # Force phone format
  $("#customer_phone").mask("(999) 999-9999")

  ### Save license image to jpegger ###
  $('.save_license_scan_to_jpegger').on 'click', ->
    device_id = $(this).data( "device-id" )
    customer_number = $(this).data( "customer-id" )
    yard_id = $(this).data( "yard-id" )
    customer_first_name = $(this).data( "customer-first-name" )
    customer_last_name = $(this).data( "customer-last-name" )
    camera_name = $(this).data( "camera-name" )
    user_icon = $(this).find( ".fa-user" )
    user_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()
    save_license_scan_to_jpegger_ajax = ->
      $.ajax
        url: "/devices/" + device_id + "/drivers_license_camera_trigger"
        dataType: 'json'
        data:
          camera_name: camera_name
          if typeof customer_first_name == 'undefined'
            customer_first_name: $('#customer_first_name').val()
          else
            customer_first_name: customer_first_name
          if typeof customer_last_name == 'undefined'
            customer_last_name: $('#customer_last_name').val()
          else
            customer_last_name: customer_last_name
          license_number: $('#customer_id_number').val()
          #dob: $('#vendor_dob').val()
          #sex: $('#vendor_sex').val()
          #license_issue_date: $('#vendor_license_issue_date').val()
          license_expiration_date: $('#customer_id_expiration').val()
          customer_number: customer_number
          event_code: "Photo ID"
          yard_id: yard_id
          address1: $('#customer_address_1').val()
          city: $('#customer_city').val()
          state: $('#customer_state').val()
          zip: $('#customer_zip').val()
        success: (data) ->
          #$('.save_to_jpegger_spinner').hide()
          spinner_icon.hide()
          user_icon.show()
          #alert 'Saved scanned image to Jpegger.'
          return
        error: ->
          spinner_icon.hide()
          user_icon.show()
          #$('.save_to_jpegger_spinner').hide()
          #alert 'Error saving scanned image to Jpegger.'
          return
    
    save_license_scan_to_jpegger_ajax()
  ### End Save license image to jpegger ###

  ### Drivers license scan ###
  $('.drivers_license_scan').on 'click', ->
    device_id = $(this).data( "device-id" )
    drivers_license_scan_ajax = ->
      $.ajax
        url: "/devices/" + device_id + "/drivers_license_scan"
        dataType: 'json'
        success: (data) ->
          firstname = data.firstname
          lastname = data.lastname
          licensenumber = data.licensenumber
          dob = data.dob
          sex = data.sex
          issue_date = data.issue_date
          expiration_date = data.expiration_date
          streetaddress = data.streetaddress
          city = data.city
          state = data.state
          zip = data.zip
          $('#customer_first_name').val firstname
          $('#customer_last_name').val lastname
          $('#customer_id_number').val licensenumber
          #$('#vendor_dob').val dob
          #$('#vendor_sex').val sex
          #$('#vendor_license_issue_date').val issue_date
          $('#customer_id_expiration').val expiration_date
          $('#customer_address_1').val streetaddress
          $('#customer_city').val city
          $('#customer_state').val state
          $('#customer_zip').val zip
          $('.data_scan_spinner').hide()
          
          return
        error: ->
          $('#spinner').hide()
          $('.data_scan_spinner').hide()
          #alert 'Error reading license.'
          return
    
    drivers_license_scan_ajax()
    ### End Drivers license scan ###

  ### Find or create by license scan ###
  $('.drivers_license_scan_and_search').on 'click', ->
    device_id = $(this).data( "device-id" )
    drivers_license_scan_and_search_ajax = ->
      $.ajax
        url: "/devices/" + device_id + "/drivers_license_scan"
        dataType: 'json'
        success: (data) ->
          firstname = data.firstname
          lastname = data.lastname
          licensenumber = data.licensenumber
          dob = data.dob
          sex = data.sex
          issue_date = data.issue_date
          expiration_date = data.expiration_date
          streetaddress = data.streetaddress
          city = data.city
          state = data.state
          zip = data.zip
          
          # Find or create vendor
          $('#q').val firstname + ' ' + lastname
          $('#first_name').val firstname
          $('#last_name').val lastname
          $('#license_number').val licensenumber
          $('#dob').val dob
          $('#sex').val sex
          $('#issue_date').val issue_date
          $('#expiration_date').val expiration_date
          $('#streetaddress').val streetaddress
          $('#city').val city
          $('#state').val state
          $('#zip').val zip
          
          $('.data_scan_spinner').hide()
          $("#customer_search_button").click()
          return
        error: ->
          $('#spinner').hide()
          $('.data_scan_spinner').hide()
          return
    
    drivers_license_scan_and_search_ajax()
    ### End Find or create by license scan ###

  ### Customer Camera Trigger ###
  $('.customer_camera_trigger').click ->
    # Get data from button
    this_customer_id = $(this).data( "customer-id" )
    this_event_code = $('#cust_pic_file_event_code').val()
    this_yard_id = $(this).data( "yard-id")
    this_camera_name = $(this).data( "camera-name" )
    this_vin_number = $('#cust_pic_file_vin_number').val()
    this_tag_number = $('#cust_pic_file_tag_number').val()
    if $('#customer_first_name').length > 0
      this_first_name = $('#customer_first_name').val()
    else
      this_first_name = $(this).data( "first-name" )
    if $('#customer_last_name').length > 0
      this_last_name = $('#customer_last_name').val()
    else
      this_last_name = $(this).data( "last-name" )
      
    camera_icon = $(this).find( ".fa-camera" )
    camera_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()

    # Make call to trigger customer camera
    $.ajax
      url: "/devices/customer_camera_trigger"
      dataType: 'json'
      data:
        customer_number: this_customer_id
        customer_first_name: this_first_name
        customer_last_name: this_last_name
        event_code: this_event_code
        yard_id: this_yard_id
        camera_name: this_camera_name
        vin_number: this_vin_number
        tag_number: this_tag_number
      success: (response) ->
        spinner_icon.hide()
        camera_icon.show()
        return
      error: ->
        spinner_icon.hide()
        camera_icon.show()
        return
  ### End Customer Camera Trigger ###

  ### Customer scale camera trigger ###
  $('.customer_scale_camera_trigger').click ->
    # Get data from button
    this_customer_id = $(this).data( "customer-id" )
    this_event_code = $('#cust_pic_file_event_code').val()
    this_yard_id = $(this).data( "yard-id")
    this_camera_name = $(this).data( "camera-name" )
    this_vin_number = $('#cust_pic_file_vin_number').val()
    this_tag_number = $('#cust_pic_file_tag_number').val()
    if $('#customer_first_name').length > 0
      this_first_name = $('#customer_first_name').val()
    else
      this_first_name = $(this).data( "first-name" )
    if $('#customer_last_name').length > 0
      this_last_name = $('#customer_last_name').val()
    else
      this_last_name = $(this).data( "last-name" )
      
    camera_icon = $(this).find( ".fa-camera" )
    camera_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()

    # Make call to trigger customer camera
    $.ajax
      url: "/devices/customer_scale_camera_trigger"
      dataType: 'json'
      data:
        customer_number: this_customer_id
        customer_first_name: this_first_name
        customer_last_name: this_last_name
        event_code: this_event_code
        yard_id: this_yard_id
        camera_name: this_camera_name
        vin_number: this_vin_number
        tag_number: this_tag_number
      success: (response) ->
        spinner_icon.hide()
        camera_icon.show()
        return
      error: ->
        spinner_icon.hide()
        camera_icon.show()
        return
  ### End Customer scale camera trigger ###

  ### Customer Scanner Trigger ###
  $('.customer_scanner_trigger').click ->
    # Get data from button
    this_customer_id = $(this).data( "customer-id" )
    this_event_code = $('#cust_pic_file_event_code').val()
    this_yard_id = $(this).data( "yard-id")
    this_camera_name = $(this).data( "camera-name" )
    this_vin_number = $('#cust_pic_file_vin_number').val()
    this_tag_number = $('#cust_pic_file_tag_number').val()
    if $('#customer_first_name').length > 0
      this_first_name = $('#customer_first_name').val()
    else
      this_first_name = $(this).data( "first-name" )
    if $('#customer_last_name').length > 0
      this_last_name = $('#customer_last_name').val()
    else
      this_last_name = $(this).data( "last-name" )
      
    scanner_icon = $(this).find( ".fa-newspaper-o" )
    scanner_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()

    # Make call to trigger customer scanner
    $.ajax
      url: "/devices/customer_scanner_trigger"
      dataType: 'json'
      data:
        customer_number: this_customer_id
        customer_first_name: this_first_name
        customer_last_name: this_last_name
        event_code: this_event_code
        yard_id: this_yard_id
        camera_name: this_camera_name
        vin_number: this_vin_number
        tag_number: this_tag_number
      success: (response) ->
        spinner_icon.hide()
        scanner_icon.show()
        #alert 'Customer scanner trigger successful.'
        return
      error: ->
        spinner_icon.hide()
        scanner_icon.show()
        #alert 'Customer scanner trigger failed'
        return
  ### End Customer Scanner Trigger ###