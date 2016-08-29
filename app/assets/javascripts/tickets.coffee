# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  wrapper = $('.ticket_input_fields_wrap')

  ### Delete of Commodity Items ###
  $(wrapper).on 'click', '.remove_field', (e) ->
    #user click on item trash button
    if $('.line-item').length > 1
      confirm1 = confirm('Are you sure you want to delete this?')
      if confirm1
        e.preventDefault()
        if $(this).hasClass('void_item')
          ticket_id = $(this).data( "ticket-id" )
          item_id = $(this).data( "item-id" )
          commodity_id = $(this).data( "commodity-id" )
          gross = $(this).data( "gross" )
          tare = $(this).data( "tare" )
          net = $(this).data( "net" )
          price = $(this).data( "price" )
          amount = $(this).data( "amount" )
          trash_icon = $(this).find( ".fa-trash" )
          trash_icon.hide()
          spinner_icon = $(this).find('.fa-spinner')
          spinner_icon.show()
          $.ajax
            url: "/tickets/void_item?ticket_id=" + ticket_id + "&item_id=" + item_id + "&commodity_id=" + commodity_id + "&gross=" + gross + "&tare=" + tare + "&net=" + net + "&price=" + price + "&amount=" + amount
            dataType: 'json'
            success: ->
              trash_icon.closest('.panel').remove()
              sum = 0;
              $('.amount').each ->
                sum += Number($(this).val())
                return
              $('#total').text '$' + sum.toFixed(2)
              $('#payment_amount').val sum.toFixed(2)
            error: ->
              spinner_icon.hide()
              trash_icon.show()
              alert 'Error voiding item.'
              return
        else
          $(this).closest('.panel').remove()
          sum = 0;
          $('.amount').each ->
            sum += Number($(this).val())
            return
          $('#total').text '$' + sum.toFixed(2)
          $('#payment_amount').val sum.toFixed(2)
        return
      else
        e.preventDefault()
        return
    else
      alert 'You cannot delete this because you must have at least one item.'
      e.preventDefault()
      return

  ### End Delete of Commodity Items ###

  ### Start endless page stuff ###
  loading_tickets = false
  $('a.load-more-tickets').on 'inview', (e, visible) ->
    return if loading_tickets or not visible
    loading_tickets = true
    if not $('a.load-more-tickets').is(':hidden')
      $('#more_tickets_spinner').show()
    $('a.load-more-tickets').hide()

    $.getScript $(this).attr('href'), ->
      loading_tickets = false
  ### End endless page stuff ###

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.ticket_button').each ->
      $.rails.enableElement $(this)
      return
    return

  ### Sum all ticket items right away ###
  $(document).on 'ready page:load', ->
    sum = 0
    $('.amount').each ->
      sum += Number($(this).val())
      return
    $('#total').text '$' + sum.toFixed(2)
    $('#ticket_total').val sum.toFixed(2)
    $('#payment_amount').val sum.toFixed(2)
    return

  # Automatically highlight field value when focused
  $('.ticket_input_fields_wrap').on 'click', '.amount-calculation-field', ->
    $(this).select()
    return

  ### Line item changed ###
  $('.ticket_input_fields_wrap').on 'change', '.item_select', ->
    item_id = $(this).val()
    input_select = $(this)
    current_customer_id = $('#ticket_customer_id').val()
    $.ajax
      url: "/commodities/" + item_id + "/price"
      dataType: 'json'
      data:
        customer_id: current_customer_id
      success: (data) ->
        name = data.name
        price = parseFloat(data.price).toFixed(3)
        #console.log 'success', price
        net = input_select.closest('.panel').find('#ticket_line_items__net:first').val()
        input_select.closest('.panel').find('.calculation_details').text ''
        input_select.closest('.panel').find('.line_item_name').text name

        input_select.closest('.panel').find('#ticket_line_items__price:first').val price
        amount = (parseFloat(price) * parseFloat(net))
        input_select.closest('.panel').find('#ticket_line_items__amount:first').val amount
        input_select.closest('.panel').find('#gross_picture_button:first').attr 'data-item-name', name 
        input_select.closest('.panel').find('#tare_picture_button:first').attr 'data-item-name', name
        input_select.closest('.panel').find('#gross_picture_button:first').attr 'data-item-id', item_id 
        input_select.closest('.panel').find('#tare_picture_button:first').attr 'data-item-id', item_id
        input_select.closest('.panel').find('#gross_scale_button:first').attr 'data-item-name', name 
        input_select.closest('.panel').find('#tare_scale_button:first').attr 'data-item-name', name
        $('.amount-calculation-field').keyup()
        return
      error: ->
        alert 'Error getting commodity price.'
        return
    return
  ### End line item changed ###

  ### Line item calculation field value changed ###
  $('.ticket_input_fields_wrap').on 'keyup', '.amount-calculation-field', ->
    gross = $(this).closest('.panel').find('#ticket_line_items__gross').val()
    tare = $(this).closest('.panel').find('#ticket_line_items__tare').val()
    net = (parseFloat(gross) - parseFloat(tare)).toFixed(2)
    $(this).closest('.panel').find('#ticket_line_items__net').val net
    $(this).closest('.panel').find('#gross_picture_button:first').attr 'data-weight', gross
    $(this).closest('.panel').find('#tare_picture_button:first').attr 'data-weight', tare

    #description = $(this).closest('.panel').find('#item_description').val()
    price = $(this).closest('.panel').find('#ticket_line_items__price').val()
    amount = (parseFloat(price) * parseFloat(net)).toFixed(2)
    $(this).closest('.panel').find('#ticket_line_items__amount').val amount

    $(this).closest('.panel').find('.calculation_details').text '(' + gross + ' - ' + tare + ') ' + '= ' + net + 'LB' + ' x '  + '$' + price + ' = ' +  '$' + amount
    sum = 0;
    $('.amount').each ->
      sum += Number($(this).val())
      return
    $('#total').text '$' + sum.toFixed(2)
    $('#ticket_total').val sum.toFixed(2)
    $('#payment_amount').val sum.toFixed(2)
    return
  ### End line item calculation field value changed ###

  ### Panel Collapse Links ###
  $(document).on 'click', '.ticket_collapse_link', (e) ->
    $(this).closest('.panel').find('.collapse_icon').toggleClass('fa-check-square ')
    return

  ### Prettier file upload buttons ###
  $('input[type=file]').bootstrapFileInput()

  ### File upload ###
  $("#new_image_file").fileupload
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
        $('#pictures').prepend('<div class="row"><div class="col-xs-12 col-sm-4 col-md-4 col-lg-4"><div class="thumbnail img-responsive"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
        $('#images').prepend('<div class="row"><div class="col-xs-12 col-sm-2 col-md-2 col-lg-2"><div class="thumbnail img-responsive"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
        $(".picture_loading_spinner").show()
      else
        alert "" + file.name + " is not a gif, jpeg, or png picture file"

    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.progress-bar').css('width', progress + '%')
  ### End file upload ###

  ### Gross/Tare Picture Uploads ###
  $('.ticket_input_fields_wrap').on 'click', '.gross_or_tare_picture_button', ->
    event_code = $(this).data( "event-code" )
    item_id = $(this).data( "item-id" )
    item_name = $(this).data( "item-name" )
    weight = $(this).data( "weight" )

    $('#image_file_event_code').val event_code
    $('#image_file_tare_seq_nbr').val item_id
    $('#image_file_commodity_name').val item_name
    $('#image_file_weight').val weight

    $('input[type=file]').trigger 'click'
    false
  ### End Gross/Tare Picture Uploads ###

  ### Clear the commodity picture upload fields for generic picture uploads ###
  $(document).on 'click', '#picture_upload_modal_link', ->
    $('#image_file_event_code').val ''
    $('#image_file_tare_seq_nbr').val ''
    $('#image_file_commodity_name').val ''
    $('#image_file_weight').val ''
    return
  ### End clear the commodity picture upload fields for generic picture uploads ###

  $('[data-toggle="popover"]').popover()

  # Dismiss popovers when click outside of popover
  $('body').on 'click', (e) ->
    $('[data-toggle="popover"]').each ->
      #the 'is' for buttons that trigger popups
      #the 'has' for icons within a button that triggers a popup
      if !$(this).is(e.target) and $(this).has(e.target).length == 0 and $('.popover').has(e.target).length == 0
        $(this).popover 'hide'
      return
    return

  # Don't require two clicks to re-show popover after clicked once already
  $('body').on 'hidden.bs.popover', (e) ->
    $(e.target).data('bs.popover').inState =
      click: false
      hover: false
      focus: false
    return

  ### Quick Payment of Ticket form Ticket Index Page ###
  # Choose a checking account to pay ticket with
  $('body').on 'click', '.checking_account', ->
    $('#finding_check_number_spinner').show()
    $('.fa-hashtag').hide()
    $('#check_number_field').show()
    checking_account_id = $(this).data( "checking-account-id" )
    checking_account_name = $(this).data( "checking-account-name" )
    $.ajax
      url: "/checking_accounts/" + checking_account_id
      dataType: 'json'
      success: (data) ->
        #console.log 'success', data
        $('#finding_check_number_spinner').hide()
        $('.fa-hashtag').show()
        $('#checking_account_payment_check_number').val data.NextNo
        $('#checking_account_payment_id').val checking_account_id
        $('#checking_account_payment_name').val checking_account_name
        return
      error: ->
        $('#finding_check_number_spinner').hide()
        $('.fa-hashtag').show()
        alert 'Error getting next check number.'
        return
    return

  # Choose cash to pay ticket with
  $('body').on 'click', '.cash_account', ->
    $('#checking_account_payment_check_number').val ''
    $('#check_number_field').hide()
    return
  ### End Quick Payment of Ticket form Ticket Index Page ###

  ### Payment within Ticket ###
  # Choose a checking account to pay ticket with
  $('#payment_form').on 'click', '.checking_account', ->
    $('#finding_check_number_spinner').show()
    $('.fa-hashtag').hide()
    $('#check_number_field').show()
    checking_account_id = $(this).data( "checking-account-id" )
    $.ajax
      url: "/checking_accounts/" + checking_account_id
      dataType: 'json'
      success: (data) ->
        #console.log 'success', data
        $('#finding_check_number_spinner').hide()
        $('.fa-hashtag').show()
        $('#checking_account_payment_check_number').val data.NextNo
        return
      error: ->
        $('#finding_check_number_spinner').hide()
        $('.fa-hashtag').show()
        alert 'Error getting next check number.'
        return
    return

  # Choose cash to pay ticket with
  $('#payment_form').on 'click', '.cash_account', ->
    $('#checking_account_payment_check_number').val ''
    $('#check_number_field').hide()
    #alert checking_account_id
    return
  ### End Payment within Ticket ###

  ### Event code changed - clear data; check if License Plate or VIN or Vehicle ###
  $('#image_file_event_code').on 'change', ->
    $('#image_file_tare_seq_nbr').val ''
    $('#image_file_commodity_name').val ''
    $('#image_file_weight').val ''
    input_select = $(this)
    if input_select.val() == 'License Plate' || input_select.val() == 'Title' || input_select.val() == 'Vehicle'
      $('#tag_form_group').show()
    else
      $('#tag_form_group').hide()
      $('#image_file_tag_number').val ''
    if input_select.val() == 'VIN' || input_select.val() == 'Title' || input_select.val() == 'Vehicle'
      $('#vin_form_group').show()
    else
      $('#vin_form_group').hide()
      $('#image_file_vin_number').val ''
    return
  ### End event code changed - clear data; check if License Plate or VIN or Vehicle ###

  ### Scale camera trigger ###
  $('#items_accordion').on 'click', '.scale_camera_trigger', (e) ->
    # Get data from scale button
    device_id = $(this).data( "device-id" )
    ticket_number = $(this).data( "ticket-number" )
    event_code = $(this).data( "event-code" )
    yard_id = $(this).data( "yard-id" )
    commodity_name = $(this).data( "item-name" )
    customer_number = $(this).data( "customer-id" )

    camera_icon = $(this).find( ".fa-camera" )
    camera_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()
    weight_text_field = $(this).closest('.input-group').find('.amount-calculation-field:first')

    # Make call to trigger scale camera
    $.ajax
      url: "/devices/" + device_id + "/scale_camera_trigger"
      dataType: 'json'
      data:
        ticket_number: ticket_number
        event_code: event_code
        commodity_name: commodity_name
        yard_id: yard_id
        weight: weight_text_field.val()
        customer_number: customer_number
      success: (response) ->
        camera_icon.show()
        spinner_icon.hide()
        #alert 'Scale camera trigger successful.'
        return
      error: ->
        camera_icon.show()
        spinner_icon.hide()
        #alert 'Scale camera trigger failed'
        return
    e.preventDefault() # Don't hop to top of page due to anchor
  ### End scale camera trigger ###

  ### Scale read and camera trigger ###
  $('#items_accordion').on 'click', '.scale_read_and_camera_trigger', (e) ->
    # Get data from scale button
    device_id = $(this).data( "device-id" )
    ticket_number = $(this).data( "ticket-number" )
    event_code = $(this).data( "event-code" )
    yard_id = $(this).data( "yard-id" )
    commodity_name = $(this).data( "item-name" )
    customer_number = $(this).data( "customer-id" )

    dashboard_icon = $(this).find( ".fa-dashboard" )
    dashboard_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()
    weight_text_field = $(this).closest('.input-group').find('.amount-calculation-field:first')
    weight = weight_text_field.val()

    # Make call to get the weight off the scale
    scale_read_ajax = ->
      $.ajax
        url: "/devices/" + device_id + "/scale_read"
        dataType: 'json'
        success: (data) ->
          weight = data.weight
          weight_text_field.val weight
          $('.ticket_input_fields_wrap .amount-calculation-field').trigger 'keyup'
          dashboard_icon.show()
          spinner_icon.hide()
          return
        error: ->
          dashboard_icon.show()
          spinner_icon.hide()
          #alert 'Error reading weight scale.'
          return

    # Make call to trigger scale camera
    camera_trigger_ajax = ->
      $.ajax
        url: "/devices/" + device_id + "/scale_camera_trigger"
        dataType: 'json'
        data:
          ticket_number: ticket_number
          event_code: event_code
          commodity_name: commodity_name
          yard_id: yard_id
          #weight: weight  
          weight: weight_text_field.val()
          customer_number: customer_number
        success: (response) ->
          #alert 'Scale camera trigger successful.'
          return
        error: ->
          #alert 'Scale camera trigger failed'
          return

    # Kick off the scale read and camera trigger ajax calls
    scale_read_ajax().success camera_trigger_ajax
    e.preventDefault() # Don't hop to top of page due to anchor
  ### End scale read and camera trigger ###

  ### Scanner Trigger ###
  $('.scanner_trigger').click ->
    # Get data from button
    this_ticket_number = $(this).data( "ticket-number" )
    device_id = $(this).data( "device-id" )
    this_event_code = $('#image_file_event_code').val()
    this_yard_id = $(this).data( "yard-id")
    this_customer_number = $(this).data( "customer-id" )
    this_vin_number = $('#image_file_vin_number').val()
    this_tag_number = $('#image_file_tag_number').val()
      
    scanner_icon = $(this).find( ".fa-newspaper-o" )
    scanner_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()

    # Make call to trigger scanner
    $.ajax
      url: "/devices/" + device_id + "/scanner_trigger"
      dataType: 'json'
      data:
        ticket_number: this_ticket_number
        event_code: this_event_code
        yard_id: this_yard_id
        customer_number: this_customer_number
        vin_number: this_vin_number
        tag_number: this_tag_number
      success: (response) ->
        spinner_icon.hide()
        scanner_icon.show()
        return
      error: ->
        spinner_icon.hide()
        scanner_icon.show()
        alert 'Scanner trigger failed'
        return
  ### End Scanner Trigger ###

  ### TUD camera trigger ###
  $('#uploads').on 'click', '.tud_camera_trigger', ->
    # Get data from scale button
    device_id = $(this).data( "device-id" )
    ticket_number = $(this).data( "ticket-number" )
    event_code = this_event_code = $('#image_file_event_code').val()
    yard_id = $(this).data( "yard-id" )
    commodity_name = $(this).data( "item-name" )
    customer_number = $(this).data( "customer-id" )
    this_vin_number = $('#image_file_vin_number').val()
    this_tag_number = $('#image_file_tag_number').val()
    

    camera_icon = $(this).find( ".fa-camera" )
    camera_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()
    weight_text_field = $(this).closest('.input-group').find('.amount-calculation-field:first')

    # Make call to trigger scale camera
    $.ajax
      url: "/devices/" + device_id + "/scale_camera_trigger"
      dataType: 'json'
      data:
        ticket_number: ticket_number
        event_code: event_code
        commodity_name: commodity_name
        yard_id: yard_id
        weight: weight_text_field.val()
        customer_number: customer_number
        vin_number: this_vin_number
        tag_number: this_tag_number
      success: (response) ->
        camera_icon.show()
        spinner_icon.hide()
        #alert 'Scale camera trigger successful.'
        return
      error: ->
        camera_icon.show()
        spinner_icon.hide()
        #alert 'Scale camera trigger failed'
        return
  ### End TUD camera trigger ###

  ### Customer camera trigger ###
  $('.customer_camera_trigger_from_ticket').click ->
    # Get data from button
    this_ticket_number = $(this).data( "ticket-number" )
    this_customer_number = $(this).data( "customer-id" )
    this_event_code = $('#image_file_event_code').val()
    this_yard_id = $(this).data( "yard-id" )
    this_camera_name = $(this).data( "camera-name" )
    this_vin_number = $('#image_file_vin_number').val()
    this_tag_number = $('#image_file_tag_number').val()

    camera_icon = $(this).find( ".fa-camera" )
    camera_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()

    # Make call to trigger customer camera
    $.ajax
      url: "/devices/customer_camera_trigger_from_ticket"
      dataType: 'json'
      data:
        ticket_number: this_ticket_number
        customer_number: this_customer_number
        event_code: this_event_code
        yard_id: this_yard_id
        camera_name: this_camera_name
        vin_number: this_vin_number
        tag_number: this_tag_number
      success: (response) ->
        spinner_icon.hide()
        camera_icon.show()
        #alert 'Customer camera trigger successful.'
        return
      error: ->
        spinner_icon.hide()
        #alert 'Customer camera trigger failed'
        return
  ### End customer camera trigger ###

  ### Scan drivers license image from ticket ###
  $('.save_license_scan_to_jpegger_from_ticket').on 'click', ->
    # Get data from button
    ticket_number = $(this).data( "ticket-number" )
    customer_number = $(this).data( "customer-id" )
    yard_id = $(this).data( "yard-id" )
    camera_name = $(this).data( "camera-name" )

    user_icon = $(this).find( ".fa-user" )
    user_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()
    save_license_scan_to_jpegger_ajax = ->
      $.ajax
        url: "/devices/drivers_license_camera_trigger_from_ticket"
        dataType: 'json'
        data:
          ticket_number: ticket_number
          customer_number: customer_number
          event_code: "Vendor"
          yard_id: yard_id
          camera_name: camera_name
        success: (data) ->
          spinner_icon.hide()
          user_icon.show()
          #alert 'Saved scanned image to Jpegger.'
          return
        error: ->
          spinner_icon.hide()
          user_icon.show()
          #alert 'Error saving scanned image to Jpegger.'
          return
    
    save_license_scan_to_jpegger_ajax()
  ### End Scan drivers license image from ticket ###

  ### TUD signature pad ###
  $('.tud_signature_pad').click ->
    # Get data from scale button
    device_id = $(this).data( "device-id" )
    ticket_number = $(this).data( "ticket-number" )
    yard_id = $(this).data( "yard-id" )
    customer_name = $(this).data( "customer-name" )
    customer_number = $(this).data( "customer-id" )

    pencil_icon = $(this).find( ".fa-pencil" )
    pencil_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()

    # Make call to trigger TUD signature pad
    $.ajax
      url: "/devices/" + device_id + "/get_signature"
      dataType: 'json'
      data:
        ticket_number: ticket_number
        yard_id: yard_id
        customer_name: customer_name
        customer_number: customer_number
      success: (response) ->
        pencil_icon.show()
        spinner_icon.hide()
        #alert 'Signature pad call successful.'
        return
      error: ->
        pencil_icon.show()
        spinner_icon.hide()
        #alert 'Signature pad call failed'
        return
  ### End TUD signature pad ###

  ### Finger print reader ###
  $('.finger_print_trigger').click ->
    # Get data from button
    device_id = $(this).data( "device-id" )
    ticket_number = $(this).data( "ticket-number" )
    yard_id = $(this).data( "yard-id" )
    customer_name = $(this).data( "customer-name" )
    customer_number = $(this).data( "customer-id" )

    pointer_icon = $(this).find( ".fa-hand-pointer-o" )
    pointer_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()

    # Make call to trigger scale camera
    $.ajax
      url: "/devices/" + device_id + "/finger_print_trigger"
      dataType: 'json'
      data:
        ticket_number: ticket_number
        yard_id: yard_id
        customer_name: customer_name
        customer_number: customer_number
      success: (response) ->
        pointer_icon.show()
        spinner_icon.hide()
        #alert 'Finger print trigger successful.'
        return
      error: ->
        pointer_icon.show()
        spinner_icon.hide()
        #alert 'Finger print trigger failed'
        return
  ### End finger print reader ###

  # Invoke select to pull pricing if new ticket comes in from work order with a commodity
  if $('.new_item').find('#ticket_line_items__commodity').val()
    $('.new_item').find('#ticket_line_items__commodity').trigger 'change'

  # Dropdown select for ticket's customer
  $('#ticket_customer_id').select2
    theme: 'bootstrap'
    minimumInputLength: 3
    ajax:
      url: '/customers'
      dataType: 'json'
      delay: 250

  ### Customer ID changed ###
  $('#ticket_customer_id').on 'change', ->
    input_select = $(this)
    customer_id = input_select.val()
    panel = input_select.closest('.panel')
    name = input_select.closest('.panel').find($( "#ticket_customer_id option:selected" )).text()
    panel.closest('.collapse').collapse('toggle')
    $(this).closest('.panel-collapse').collapse('hide')
    input_select.closest('.panel').find('#vendor_name').text name
    $('.item_select').trigger 'change' # Re-select line items in case new pricing needs to be applied
  ### End Customer ID changed ###