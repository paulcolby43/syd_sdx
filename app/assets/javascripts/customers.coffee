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
    save_license_scan_to_jpegger_ajax = ->
      $.ajax
        url: "/devices/" + device_id + "/drivers_license_camera_trigger"
        dataType: 'json'
        data:
          customer_first_name: $('#customer_first_name').val()
          customer_last_name: $('#customer_last_name').val()
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
          $('.save_to_jpegger_spinner').hide()
          #alert 'Saved scanned image to Jpegger.'
          return
        error: ->
          $('.save_to_jpegger_spinner').hide()
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