# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Delete of Packs ###
  $('.pack_list_pack_fields_wrap').on 'click', '.remove_field', (e) ->
    #user click on pack trash button
    if $('.pack').length > 1
      confirm1 = confirm('Are you sure you want to remove this pack?')
      if confirm1
        e.preventDefault()
        trash_icon = $(this).find( ".fa-trash" )
        trash_icon.closest('.panel').remove()
        #calculate_net_total()
        return

          #ticket_id = $(this).data( "ticket-id" )
          #item_id = $(this).data( "item-id" )
          #commodity_id = $(this).data( "commodity-id" )
          #gross = $(this).data( "gross" )
          #tare = $(this).data( "tare" )
          #net = $(this).data( "net" )
          #price = $(this).data( "price" )
          #amount = $(this).data( "amount" )
          #trash_icon = $(this).find( ".fa-trash" )
          #trash_icon.hide()
          #spinner_icon = $(this).find('.fa-spinner')
          #spinner_icon.show()
          #$.ajax
          #  url: "/tickets/void_item?ticket_id=" + ticket_id + "&item_id=" + item_id + "&commodity_id=" + commodity_id + "&gross=" + gross + "&tare=" + tare + "&net=" + net + "&price=" + price + "&amount=" + amount
          #  dataType: 'json'
          #  success: ->
          #    trash_icon.closest('.panel').remove()
          #    sum = 0;
          #    $('.amount').each ->
          #      sum += Number($(this).val())
          #      return
          #    $('#total').text '$' + sum.toFixed(2)
          #    $('#payment_amount').val sum.toFixed(2)
          #  error: ->
          #    spinner_icon.hide()
          #    trash_icon.show()
          #    alert 'Error voiding item.'
          #    return
        #else
        #  $(this).closest('.panel').remove()
        #  sum = 0;
        #  $('.amount').each ->
        #    sum += Number($(this).val())
        #    return
        #  $('#total').text '$' + sum.toFixed(2)
        #  $('#payment_amount').val sum.toFixed(2)
        #return
      else
        e.preventDefault()
        return
    else
      alert 'You cannot delete this because you must have at least one pack.'
      e.preventDefault()
      return

  ### End Delete of Packs ###

  ### Start endless page stuff ###
  loading_packs = false
  $('a.load-more-packs').on 'inview', (e, visible) ->
    return if loading_packs or not visible
    loading_packs = true
    if not $('a.load-more-packs').is(':hidden')
      $('#more_packs_spinner').show()
    $('a.load-more-packs').hide()

    $.getScript $(this).attr('href'), ->
      loading_packs = false
  ### End endless page stuff ###

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.pack_list_button').each ->
      $.rails.enableElement $(this)
      return
    return

  # Dropdown select for pack list's packs
  $('.pack_select').select2
    theme: 'bootstrap'
    minimumInputLength: 3
    ajax:
      url: '/packs?status=0'
      dataType: 'json'
      delay: 250

  ### pack changed ###
  $('.pack_list_pack_fields_wrap').on 'change', '.pack_select', ->
    pack_id = $(this).val()
    pack_select = $(this)
    # current_customer_id = $('#ticket_customer_id').val()
    # Get pack description, gross, tare, net, then update.
    get_pack_info_ajax = ->
      $.ajax
        url: "/packs/" + pack_id
        dataType: 'json'
        success: (data) ->
          name = data.name
          internal_pack_number = data.internal_pack_number
          tag_number = data.tag_number
          gross = data.gross
          tare = data.tare
          net = data.net
          pack_select.closest('.panel').find('#pack_list_packs__print_description:first').val name
          pack_select.closest('.panel').find('.pack_name').text name
          pack_select.closest('.panel').find('#pack_list_packs__internal_pack_number:first').val internal_pack_number
          pack_select.closest('.panel').find('#pack_list_packs__tag_number:first').val tag_number
          pack_select.closest('.panel').find('#pack_list_packs__gross:first').val gross
          pack_select.closest('.panel').find('#pack_list_packs__tare:first').val tare
          pack_select.closest('.panel').find('#pack_list_packs__net:first').val net
          
          calculate_net_total()
          # The add pack to pack list
          add_pack_ajax()

          return
        error: ->
          alert 'Error getting pack information.'
          console.log 'Error getting pack information.'
          return
    add_pack_ajax = ->
      $.ajax
        url: "/pack_lists/" + pack_id + "/add_pack"
        dataType: 'json'
        data:
          internal_pack_number: pack_select.closest('.panel').find('#pack_list_packs__internal_pack_number:first').val()
          tag_number: pack_select.closest('.panel').find('#pack_list_packs__tag_number:first').val()
        success: (data) ->
          alert 'Pack successfully added'
          return
        error: ->
          alert 'Error adding pack to pack list.'
          console.log 'Error adding pack to pack list.'
          return
    if pack_id != ''
      # Only get pack info if there is a pack
      get_pack_info_ajax()
    return
  ### End pack changed ###

  ### Pack calculation field value changed ###
  $('.pack_list_pack_fields_wrap').on 'keyup', '.amount-calculation-field', ->
    changed_field = $(this)
    gross = $(this).closest('.panel').find('#pack_list_packs__gross').val()
    tare = $(this).closest('.panel').find('#pack_list_packs__tare').val()
    net = (parseFloat(gross) - parseFloat(tare)).toFixed(2)
    changed_field.closest('.panel').find('#pack_list_packs__net').val net
    changed_field.closest('.panel').find('#gross_picture_button:first').attr 'data-weight', gross
    changed_field.closest('.panel').find('#tare_picture_button:first').attr 'data-weight', tare

    calculate_net_total()

    return
  ### End pack calculation field value changed ###

  calculate_net_total = ->
    sum = 0
    $('.net').each ->
      sum += Number($(this).val())
      return
    $('#net_total').text sum.toFixed(2)
    return
    

  ### Sum all packs right away ###
  $(document).on 'ready page:load', ->
    calculate_net_total()