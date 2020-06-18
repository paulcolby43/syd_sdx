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
          session_id = $(this).data( "session-id" )
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
            #url: "/tickets/void_item?ticket_id=" + ticket_id + "&item_id=" + item_id + "&commodity_id=" + commodity_id + "&gross=" + gross + "&tare=" + tare + "&net=" + net + "&price=" + price + "&amount=" + amount
            url: "/tickets/void_item"
            dataType: 'json'
            data:
              ticket_id: ticket_id
              session_id: session_id
              item_id: item_id
              commodity_id: commodity_id
              gross: gross
              tare: tare
              net: net
              price: price
              amount: amount
            success: ->
              trash_icon.closest('.panel').remove()
              sum = 0;
              # Add up amounts
              $('.amount').each ->
                sum += Number($(this).val())
                return
              # Add up taxes
              $('.tax').each ->
                sum += Number($(this).val())
                return
              # Add up deduction dollar amounts
              deduction_dollar_amount = 0
              $('.deduction_dollar_amount').each ->
                deduction_dollar_amount += Number($(this).val())
                return
              $('#total').text '$' + (parseFloat(sum) - parseFloat(deduction_dollar_amount)).toFixed(2)
              $('#payment_amount').val (parseFloat(sum) - parseFloat(deduction_dollar_amount)).toFixed(2)
            error: ->
              spinner_icon.hide()
              trash_icon.show()
              alert 'Error voiding item.'
              return
        else
          $(this).closest('.panel').remove()
          sum = 0;
          # Add up amounts
          $('.amount').each ->
            sum += Number($(this).val())
            return
          # Add up taxes
          $('.tax').each ->
            sum += Number($(this).val())
            return
          # Add up deduction dollar amounts
          deduction_dollar_amount = 0
          $('.deduction_dollar_amount').each ->
            deduction_dollar_amount += Number($(this).val())
            return
          $('#total').text '$' + (parseFloat(sum) - parseFloat(deduction_dollar_amount)).toFixed(2)
          $('#payment_amount').val (parseFloat(sum) - parseFloat(deduction_dollar_amount)).toFixed(2)
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
    # Add up amounts
    $('.amount').each ->
      sum += Number($(this).val())
      return
    # Add up taxes
    $('.tax').each ->
      sum += Number($(this).val())
      return
    # Add up deduction dollar amounts
    #deduction_dollar_amount = 0
    #$('.deduction_dollar_amount').each ->
    #  deduction_dollar_amount += Number($(this).val())
    #  return
    $('#total').text '$' + (parseFloat(sum)).toFixed(2)
    $('#ticket_total').val (parseFloat(sum)).toFixed(2)
    $('#payment_amount').val (parseFloat(sum)).toFixed(2)
    return

  # Automatically highlight field value when focused
  $('.ticket_input_fields_wrap').on 'click', '.amount-calculation-field', ->
    $(this).select()
    return

  ### Line item changed ###
  $('.ticket_input_fields_wrap').on 'change', '.item_select', ->
    console.log '.item_select changed', 'yes'
    ticket_id = $(this).data( "ticket-id" )
    session_id = $(this).data( "session-id" )
    item_id = $(this).data( "item-id" )
    commodity_id = $(this).val()
    commodity_name = $(this).find('option:selected').text()
    input_select = $(this)
    current_customer_id = $('#ticket_customer_id').val()
    ticket_item_status = input_select.closest('.panel').find('#ticket_line_items__status:first').val()
    session_id = $(this).data( "session-id" )
    # Get commodity price, unit of measure, and taxes, then update.
    get_commodity_info_ajax = ->
      $.ajax
        url: "/commodities/" + commodity_id + "/price"
        dataType: 'json'
        data:
          customer_id: current_customer_id
        success: (data) ->
          name = data.name
          price = parseFloat(data.price).toFixed(3)
          unit_of_measure = data.unit_of_measure
          console.log 'price', price
          tax_percent_1 = parseFloat(data.tax_percent_1).toFixed(2)
          tax_percent_2 = parseFloat(data.tax_percent_2).toFixed(2)
          tax_percent_3 = parseFloat(data.tax_percent_3).toFixed(2)
          console.log 'tax percent 1:', tax_percent_1
          console.log 'tax percent 2:', tax_percent_2
          console.log 'tax percent 3:', tax_percent_3
          #console.log 'unit of measure:', unit_of_measure
          net = input_select.closest('.panel').find('#ticket_line_items__net:first').val()
          input_select.closest('.panel').find('.calculation_details').text ''
          input_select.closest('.panel').find('.line_item_name').text name

          input_select.closest('.panel').find('#ticket_line_items__price:first').val price
          input_select.closest('.panel').find('#ticket_line_items__unit_of_measure:first').val unit_of_measure
          amount = (parseFloat(price) * parseFloat(net))
          input_select.closest('.panel').find('#ticket_line_items__tax_percent_1:first').val parseFloat(tax_percent_1).toFixed(2)
          input_select.closest('.panel').find('#ticket_line_items__tax_percent_2:first').val parseFloat(tax_percent_2).toFixed(2)
          input_select.closest('.panel').find('#ticket_line_items__tax_percent_3:first').val parseFloat(tax_percent_3).toFixed(2)
          input_select.closest('.panel').find('#ticket_line_items__tax_amount_1:first').val parseFloat(tax_percent_1 * amount).toFixed(2)
          input_select.closest('.panel').find('#ticket_line_items__tax_amount_2:first').val parseFloat(tax_percent_2 * amount).toFixed(2)
          input_select.closest('.panel').find('#ticket_line_items__tax_amount_3:first').val parseFloat(tax_percent_3 * amount).toFixed(2)
          input_select.closest('.panel').find('#ticket_line_items__amount:first').val amount
          input_select.closest('.panel').find('#gross_picture_button:first').attr 'data-item-name', name 
          input_select.closest('.panel').find('#tare_picture_button:first').attr 'data-item-name', name
          input_select.closest('.panel').find('#gross_picture_button:first').attr 'data-item-id', commodity_id 
          input_select.closest('.panel').find('#tare_picture_button:first').attr 'data-item-id', commodity_id
          input_select.closest('.panel').find('#gross_scale_button:first').attr 'data-item-name', name 
          input_select.closest('.panel').find('#tare_scale_button:first').attr 'data-item-name', name
          #input_select.closest('.panel').find('.amount-calculation-field:first').keyup() # Invoke 'keyup' so go through calculations again
          input_select.closest('.panel').find('.amount-calculation-field:first').change() # Invoke 'change' so go through calculations again

          if ticket_item_status != '0' # New ticket item that needs to be added/saved to ticket
            ticket_item_add_ajax()
          
          return
        error: ->
          alert 'Error getting commodity price.'
          console.log 'Error getting commodity price.'
          return
    ticket_item_add_ajax = ->
      price = input_select.closest('.panel').find('#ticket_line_items__price:first').val()
      $.ajax
        url: "/ticket_items/" + item_id + "/quick_add"
        dataType: 'json'
        method: 'POST'
        data:
          ticket_id: ticket_id
          commodity_id: commodity_id
          commodity_name: commodity_name
          price: price
          session_id: session_id
        success: (data) ->
          success = data.success
          failure_information = data.failure_information
          if success == 'true' 
            console.log 'ticket item quick add successful'
            input_select.closest('.panel').find('#ticket_line_items__status:first').val '0' # Set newly added item status to 0 so don't try to add again
            input_select.closest('.panel').find('.remove_field:first').addClass( 'void_item' )
            #input_select.closest('.panel').find('.remove_field:first').data 'commodity-id', commodity_id
            input_select.closest('.panel').find('.remove_field:first').attr 'data-commodity-id', commodity_id
            $("#more_" + item_id + "_link").show()
          else
            alert 'Error saving ticket line item. ' + failure_information
            console.log 'Error saving ticket line item. ' + failure_information
          return
        error: ->
          alert 'Error saving ticket line item.'
          console.log 'Error saving ticket line item.'
          return
    if commodity_id != ''
      # Only get commodity info if there is a commodity item
      get_commodity_info_ajax()
    return
  ### End line item changed ###

  ### Line item calculation field value changed ###
  # $('.ticket_input_fields_wrap').on 'keyup', '.amount-calculation-field', ->
  $('.ticket_input_fields_wrap').on 'change', '.amount-calculation-field', ->
    console.log '.amount-calculation-field changed', 'yes'
    $('#hold_close_pay_buttons').hide();
    $('#calculating').show();
    changed_field = $(this)
    quantity = $(this).closest('.panel').find('#ticket_line_items__quantity').val()
    gross = $(this).closest('.panel').find('#ticket_line_items__gross').val()
    tare = $(this).closest('.panel').find('#ticket_line_items__tare').val()
    line_item_dollar_amount_deductions_total = 0
    $(this).closest('.panel').find('.deduction_dollar_amount').each ->
      line_item_dollar_amount_deductions_total += Number($(this).val())
      return
    line_item_weight_deductions_total = 0
    $(this).closest('.panel').find('.deduction_weight').each ->
      line_item_weight_deductions_total += Number($(this).val())
      return
    if changed_field.closest('.panel').find('#ticket_line_items__tax_percent_1').length
      tax_percent_1 = changed_field.closest('.panel').find('#ticket_line_items__tax_percent_1').val()
    else 
      tax_percent_1 = '0.00'
    if changed_field.closest('.panel').find('#ticket_line_items__tax_percent_2').length
      tax_percent_2 = changed_field.closest('.panel').find('#ticket_line_items__tax_percent_2').val()
    else 
      tax_percent_2 = '0.00'
    if changed_field.closest('.panel').find('#ticket_line_items__tax_percent_3').length
      tax_percent_3 = changed_field.closest('.panel').find('#ticket_line_items__tax_percent_3').val()
    else 
      tax_percent_3 = '0.00'
    net = (parseFloat(gross) - parseFloat(tare) - parseFloat(line_item_weight_deductions_total)).toFixed(2)
    changed_field.closest('.panel').find('#ticket_line_items__net').val net
    changed_field.closest('.panel').find('#gross_picture_button:first').attr 'data-weight', gross
    changed_field.closest('.panel').find('#tare_picture_button:first').attr 'data-weight', tare

    #description = $(this).closest('.panel').find('#item_description').val()
    price = changed_field.closest('.panel').find('#ticket_line_items__price').val()
    unit_of_measure = changed_field.closest('.panel').find('#ticket_line_items__unit_of_measure').val()
    console.log 'unit of measure', unit_of_measure
    if unit_of_measure == 'EA'
      changed_field.closest('.panel').find('#quantity_form_field').show()
      changed_field.closest('.panel').find('#gross_and_tare_form_field').hide()
    else
      changed_field.closest('.panel').find('#quantity_form_field').hide()
      changed_field.closest('.panel').find('#gross_and_tare_form_field').show()
      
    #tax_amount_1 = (parseFloat(tax_percent_1) * (parseFloat(price) * parseFloat(net))).toFixed(2)
    #tax_amount_2 = (parseFloat(tax_percent_2) * (parseFloat(price) * parseFloat(net))).toFixed(2)
    #total_tax_amount = (parseFloat(tax_amount_1) + parseFloat(tax_amount_2)).toFixed(2)
    #changed_field.closest('.panel').find('#ticket_line_items__tax_amount_1').val tax_amount_1
    #changed_field.closest('.panel').find('#ticket_line_items__tax_amount_2').val tax_amount_2

    # Get unit of measure weight conversion for commodity item
    item_id = changed_field.closest('.panel').find('#ticket_line_items__commodity').val()
    line_item_unit_of_measure = changed_field.closest('.panel').find('#ticket_line_items__unit_of_measure').val()
    get_commodity_unit_of_measure_weight_conversion_ajax = ->
      $.ajax
        #url: "/commodities/" + item_id + "/unit_of_measure_weight_conversion"
        url: "/commodities/unit_of_measure_lb_conversion"
        dataType: 'json'
        #delay: 500 # Wait so that net can be re-calculated
        data:
          net: net
          unit_of_measure: line_item_unit_of_measure
        success: (data) ->
          new_weight = data.new_weight
          console.log 'new_weight', data
          if line_item_unit_of_measure != 'LD'
            if line_item_unit_of_measure == 'EA'
              amount = (parseFloat(price) * parseFloat(quantity) - parseFloat(line_item_dollar_amount_deductions_total)).toFixed(2)
            else
              amount = (parseFloat(price) * parseFloat(new_weight) - parseFloat(line_item_dollar_amount_deductions_total)).toFixed(2)
          else 
            amount = (parseFloat(price) - parseFloat(line_item_dollar_amount_deductions_total)).toFixed(2)
          console.log 'amount:', amount
          changed_field.closest('.panel').find('#ticket_line_items__amount').val amount

          # Update tax amount to account for possibility that unit of measure is different than price measurement, making a 'new weight'
          tax_amount_1 = (parseFloat(tax_percent_1) * (parseFloat(price) * parseFloat(new_weight))).toFixed(2)
          tax_amount_2 = (parseFloat(tax_percent_2) * (parseFloat(price) * parseFloat(new_weight))).toFixed(2)
          tax_amount_3 = (parseFloat(tax_percent_3) * (parseFloat(price) * parseFloat(new_weight))).toFixed(2)
          total_tax_amount = (parseFloat(tax_amount_1) + parseFloat(tax_amount_2) + parseFloat(tax_amount_3)).toFixed(2)
          changed_field.closest('.panel').find('#ticket_line_items__tax_amount_1').val tax_amount_1
          changed_field.closest('.panel').find('#ticket_line_items__tax_amount_2').val tax_amount_2
          changed_field.closest('.panel').find('#ticket_line_items__tax_amount_3').val tax_amount_3
          
          # Update calculation details in panel footer
          if line_item_unit_of_measure == 'EA'
            changed_field.closest('.panel').find('.calculation_details').html '<strong>Quantity:</strong> ' + quantity + ' &nbsp;$' + price + '/' + unit_of_measure + '  ' + ' &nbsp;<strong>$' + (parseFloat(amount)).toFixed(2) + '</strong>'
          else
            changed_field.closest('.panel').find('.calculation_details').html '<strong>Gross:</strong> ' + gross + ' &nbsp;<strong>Tare:</strong> ' + tare + ' &nbsp;<strong>Net:</strong> ' + net + ' LB' + ' &nbsp;$' + price + '/' + unit_of_measure + '  ' + ' &nbsp;<strong>$' + (parseFloat(amount)).toFixed(2) + '</strong>'
          if line_item_dollar_amount_deductions_total > 0
            changed_field.closest('.panel').find('.dollar_amount_deduction_details').html '<strong>Less:</strong> $' + line_item_dollar_amount_deductions_total
          if line_item_weight_deductions_total > 0
            changed_field.closest('.panel').find('.weight_deduction_details').html '<strong>Less:</strong> ' + line_item_weight_deductions_total + ' LB'
          if total_tax_amount > 0
            changed_field.closest('.panel').find('.tax_details').html '<strong>Taxes:</strong> $' + total_tax_amount
              
          sum = 0;
          # Add up amounts
          $('.amount').each ->
            sum += Number($(this).val())
            return
          # Add up taxes
          $('.tax').each ->
            sum += Number($(this).val())
            return
          
          # Add up deduction dollar amounts
          #deduction_dollar_amount = 0
          #$('.deduction_dollar_amount').each ->
          #  deduction_dollar_amount += Number($(this).val())
          #  return
          $('#total').text '$' + (parseFloat(sum)).toFixed(2)
          $('#ticket_total').val (parseFloat(sum)).toFixed(2)
          $('#payment_amount').val (parseFloat(sum)).toFixed(2)
          $('#hold_close_pay_buttons').show();
          $('#calculating').hide();
          return
        error: ->
          alert 'Error getting commodity unit of measure conversion.'
          console.log 'Error getting commodity unit of measure conversion.'
          $('#hold_close_pay_buttons').show();
          $('#calculating').hide();
          return
    if item_id != ''
      get_commodity_unit_of_measure_weight_conversion_ajax()

    #amount = (parseFloat(price) * parseFloat(net)).toFixed(2)

    return
  ### End line item calculation field value changed ###

  ### Panel Collapse Links ###
  $(document).on 'click', '.ticket_collapse_link', (e) ->
    $(this).closest('.panel').find('.collapse_icon').toggleClass('fa-check-square ')
    return

  ### Prettier file upload buttons ###
  $('input[type=file]').bootstrapFileInput()

  ### File upload ###
  #$("#new_image_file").fileupload
  $(".image_file_upload_form").fileupload
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
        form = $(this).closest("form")
        form.find('#pictures').prepend('<div class="row"><div class="col-xs-12 col-sm-4 col-md-4 col-lg-4"><div class="thumbnail img-responsive"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
        # $('#pictures').prepend('<div class="row"><div class="col-xs-12 col-sm-4 col-md-4 col-lg-4"><div class="thumbnail img-responsive"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
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
    #event_code = $(this).data( "event-code" )
    event_code_id = $(this).data( "event-code-id" )
    item_id = $(this).data( "item-id" )
    item_name = $(this).data( "item-name" )
    weight = $(this).data( "weight" )
    $('#image_file_event_code_id_' + event_code_id).prop 'checked', true
    #$('#image_file_event_code').val event_code
    $('#image_file_tare_seq_nbr').val item_id
    $('#image_file_commodity_name').val item_name
    $('#image_file_weight').val weight

    $('input[type=file]').trigger 'click'
    false
  ### End Gross/Tare Picture Uploads ###

  ### Quantity Picture Uploads ###
  $('.ticket_input_fields_wrap').on 'click', '.quantity_picture_button', ->
    item_id = $(this).data( "item-id" )
    item_name = $(this).data( "item-name" )
    $('#image_file_tare_seq_nbr').val item_id
    $('#image_file_commodity_name').val item_name
    $('input[type=file]').trigger 'click'
    false
  ### End Quantity Picture Uploads ###

  ### Clear the commodity picture upload fields for generic picture uploads ###
  $(document).on 'click', '#picture_upload_modal_link', ->
    $('#image_file_event_code_id').val ''
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

  ### Event code clicked - clear data ###
  $('#event_code').on 'click', (e) ->
    $('#image_file_tare_seq_nbr').val ''
    $('#image_file_commodity_name').val ''
    $('#image_file_weight').val ''
    return
  ### End event code changed - clear data ###

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
          # $('.ticket_input_fields_wrap .amount-calculation-field').trigger 'keyup'
          $('.ticket_input_fields_wrap .amount-calculation-field').trigger 'change'
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
    language: noResults: ->
      #'No customers found. <button onclick="open_new_customer_modal(); " class="btn btn-primary btn-sm">Create</button>'
      'No customers found. <a href = "/customers/new" target="_blank;"><i class="fa fa-plus"></i> Add</a>'
    escapeMarkup: (markup) ->
      markup
    ajax:
      url: '/customers'
      dataType: 'json'
      delay: 250

  # Dropdown select for ticket commodities
  $('.item_select').select2
    theme: 'bootstrap'
    minimumInputLength: 2
    ajax:
      url: '/commodities'
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

  ### Ticket picture event code chosen ###
  #$(".event_code_radio").on 'click', ->
  $('#individual_ticket_upload').on 'click', '.event_code_radio', (e) ->
    form = $(this).closest("form")
    upload_button_div = form.find('#upload_button')
    devices_div = form.find('#devices')
    if devices_div.length > 0
      devices_div.show()
      upload_button_div.show()
    else
      form.find('#image_file_file').click()
    
  ### Tickets index picture event code chosen ###
  $('#tickets').on 'click', '.event_code_radio', (e) ->
    form = $(this).closest("form")
    upload_button_div = form.find('#upload_button')
    devices_div = form.find('#devices')
    if devices_div.length > 0
      devices_div.show()
      upload_button_div.show()
    else
      form.find('#image_file_file').click()

  ### VIN Search ###
  $(wrapper).on 'click', '.vin_search_button', (e) ->
    modal = $(this).closest('.modal')
    vin_number = modal.find('#vin_number').val()
    results_div = modal.find('#results')
    year_select = modal.find('#date_ticket_item_year')
    make_select = modal.find('#ticket_item_make_id')
    model_select = modal.find('#ticket_item_model_id')
    body_select = modal.find('#ticket_item_body_id')
    color_select = modal.find('#ticket_item_color_id')
    results_div = modal.find('#results')
    search_icon = $(this).find( ".fa-search" )
    search_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()
    results_div.hide()
    $.ajax
      url: "/tickets/vin_search"
      dataType: 'json'
      data:
        vin: vin_number
      success: (data) ->
        search_icon.show()
        spinner_icon.hide()
        valid = data.valid
        year = data.year
        make = data.make
        make_id = data.make_id
        added_make = data.added_make
        model = data.model
        model_id = data.model_id
        added_model = data.added_model
        body = data.body
        body_id = data.body_id
        added_body = data.added_body
        if valid == 'true'
          if added_make == 'true'
            make_select.append( '<option value="' + make_id + '">' + make + '</option>' )
          if added_model == 'true'
            model_select.append( '<option value="' + model_id + '">' + model + '</option>' )
          if added_body == 'true'
            body_select.append( '<option value="' + body_id + '">' + body + '</option>' )
          results_div.show()
          year_select.val year
          make_select.val make_id
          model_select.val model_id
          body_select.val body_id
        else
          alert 'Not a valid VIN'
        return
      error: ->
        search_icon.show()
        spinner_icon.hide()
        alert 'VIN search failed'
        return
    return
  ### End VIN Search ###

  ### Save VIN Info ###
  #$(document).on 'click', '.save_vin_info_button', (e) ->
  $(wrapper).on 'click', '.save_vin_info_button', (e) ->
    modal = $(this).closest('.modal')
    existing_car_details_div = modal.find('#existing_car_details')
    item_id = modal.find('#ticket_item_id').val()
    vehicle_id_number = modal.find('#vin_number').val()
    year_select = modal.find('#date_ticket_item_year')
    year = year_select.val()
    make_select = modal.find('#ticket_item_make_id')
    make_id = make_select.val()
    make = make_select.find('option:selected').text()
    model_select = modal.find('#ticket_item_model_id')
    model_id = model_select.val()
    model = model_select.find('option:selected').text()
    body_select = modal.find('#ticket_item_body_id')
    body_id = body_select.val()
    body = body_select.find('option:selected').text()
    color_select = modal.find('#ticket_item_color_id')
    color_id = color_select.val()
    color = color_select.find('option:selected').text()
    save_icon = $(this).find( ".fa-cloud-upload" )
    save_icon.hide()
    spinner_icon = $(this).find('.fa-spinner')
    spinner_icon.show()
    $.ajax
      url: "/ticket_items/" + item_id + "/save_vin"
      dataType: 'json'
      method: 'POST'
      data:
        vehicle_id_number: vehicle_id_number
        year: year
        make_id: make_id
        model_id: model_id
        body_id: body_id
        color_id: color_id
      success: (data) ->
        spinner_icon.hide()
        save_icon.show()
        success = data.success
        failure_information = data.failure_information
        if success == 'true'
          #alert 'success'
          existing_car_details_div.prepend( '<div class="well">' + vehicle_id_number + '<br>' + year + ' ' + color + ' ' + make + ' ' + model + ' ' + body + '</div>')
          console.log 'save VIN successful'
        else
          alert failure_information
        modal.modal('hide')
        return
      error: ->
        spinner_icon.hide()
        save_icon.show()
        alert 'Error saving VIN information'
        modal.modal('hide')
        return
    return
  ### End Save VIN Info ###

  $('.vin_search_field').keydown (e) ->
    if e.keyCode == 13
      event.preventDefault()
      modal = $(this).closest('.modal')
      search_button = modal.find('.vin_search_button')
      search_button.click()
    return

  ### Start VIN Barcode Scanner ###
  order_by_occurrence = (arr) ->
    counts = {}
    arr.forEach (value) ->
      if !counts[value]
        counts[value] = 0
      counts[value]++
      return
    Object.keys(counts).sort (curKey, nextKey) ->
      counts[curKey] < counts[nextKey]

  load_vin_barcode_scanner = (item_id) ->
    barcode_scanner_div = "#vin_barcode_scanner_" + item_id
    if $(barcode_scanner_div).length > 0 and navigator.mediaDevices and typeof navigator.mediaDevices.getUserMedia == 'function'
      last_result = []
      if Quagga.initialized == undefined
        Quagga.onProcessed (result) ->
          drawingCtx = Quagga.canvas.ctx.overlay
          drawingCanvas = Quagga.canvas.dom.overlay
          if result
            if result.boxes
              drawingCtx.clearRect 0, 0, parseInt(drawingCanvas.getAttribute('width')), parseInt(drawingCanvas.getAttribute('height'))
              result.boxes.filter((box) ->
                box != result.box
              ).forEach (box) ->
                Quagga.ImageDebug.drawPath box, {
                  x: 0
                  y: 1
                }, drawingCtx,
                  color: 'green'
                  lineWidth: 3
                return
            if result.box
              Quagga.ImageDebug.drawPath result.box, {
                x: 0
                y: 1
              }, drawingCtx,
                color: '#00F'
                lineWidth: 3
            if result.codeResult and result.codeResult.code
              Quagga.ImageDebug.drawPath result.line, {
                x: 'x'
                y: 'y'
              }, drawingCtx,
                color: 'red'
                lineWidth: 4
          return
        Quagga.onDetected (result) ->
          last_code = result.codeResult.code
          last_result.push last_code
          if last_result.length > 20
            code = order_by_occurrence(last_result)[0]
            last_result = []
            console.log code
            console.log result.codeResult.format
            $('.vin_search_field').val(code)
            Quagga.stop()
            $('.vin_barcode_scanner').empty()
          return
      Quagga.init {
        inputStream:
          name: 'Live'
          type: 'LiveStream'
          numOfWorkers: navigator.hardwareConcurrency
          target: document.querySelector(barcode_scanner_div)
        decoder: readers: [
          #'ean_reader'
          #'ean_8_reader'
          'code_39_reader'
          'code_39_vin_reader'
          #'codabar_reader'
          #'upc_reader'
          #'upc_e_reader'
        ]
      }, (err) ->
        if err
          console.log err
          return
        Quagga.initialized = true
        Quagga.start()
        return
    return

  #$('.car_details').on 'click', '.vin_barcode_search_button', (e) ->
  $(document).on 'click', '.vin_barcode_search_button', (e) ->
    $('.vin_search_field').val('')
    item_id = $(this).data( "item-id" )
    load_vin_barcode_scanner(item_id)
  
  ### End VIN Barcode Scanner ###

  ### Don't submit form if press enter key when in the serial number field ###
  $(document).on 'keydown', '.serial_number_field', (e) ->
    code = e.keyCode or e.which
    if code == 13 and !jQuery(e.target).is('textarea,input[type="submit"],input[type="button"]')
      e.preventDefault()
      return false
    return