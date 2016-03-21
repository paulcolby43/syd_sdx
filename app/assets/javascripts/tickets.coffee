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
              return
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
    $.ajax(url: "/commodities/" + item_id, dataType: 'json').done (data) ->
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

  $ ->
    $('[data-toggle="popover"]').popover()
    return

  ### Payments ###
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
  ### End Payments ###