# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Remove pack from pack list ###
  $('#current_packs').on 'click', '.remove_pack', (e) ->
    #user click on pack trash button
    if $('.pack').length > 1
      confirm1 = confirm('Are you sure you want to delete this?')
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

  ### End remove pack from pack list ###

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.pack_shipment_button').each ->
      $.rails.enableElement $(this)
      return
    return

  # Dropdown select for shipment's pack list packs
  $('.shipment_pack_select').select2
    theme: 'bootstrap'
    minimumInputLength: 3
    ajax:
      url: '/packs?status=0'
      dataType: 'json'
      delay: 250

  ### pack selected ###
  $('#pack_details').on 'change', '.shipment_pack_select', ->
    pack_id = $(this).val()
    pack_list_id = $(this).data( "pack-list-id" )
    pack_shipment_id = $(this).data( "pack-shipment-id" )
    pack_select = $(this)
    adding_pack_spinner_icon = pack_select.closest('#pack_details').find('.adding_pack_spinner:first')
    adding_pack_spinner_icon.show()
    get_pack_info_ajax = ->
      $.ajax
        url: "/packs/" + pack_id
        dataType: 'json'
        success: (data) ->
          name = data.name
          internal_pack_number = data.internal_pack_number
          tag_number = data.tag_number

          pack_select.closest('#pack_details').find('#internal_pack_number:first').val internal_pack_number
          pack_select.closest('#pack_details').find('#tag_number:first').val tag_number
          pack_select.closest('#pack_details').find('#pack_description:first').val name

          console.log 'Name', name
          console.log 'Internal Pack Number', internal_pack_number
          add_pack_to_pack_list_ajax()
          return
        error: ->
          adding_pack_spinner_icon.hide()
          alert 'Error getting pack information.'
          console.log 'Error getting pack information.'
          return
    add_pack_to_pack_list_ajax = ->
      $.ajax
        url: "/pack_lists/" + pack_list_id + "/add_pack"
        dataType: 'json'
        data:
          internal_pack_number: pack_select.closest('#pack_details').find('#internal_pack_number:first').val()
          tag_number: pack_select.closest('#pack_details').find('#tag_number:first').val()
        success: (data) ->
          console.log 'Pack added to pack list'
          add_pack_to_pack_list_html_ajax()
          $('.shipment_pack_select').select2('open');

          return
        error: (xhr) ->
          error = $.parseJSON(xhr.responseText).error
          adding_pack_spinner_icon.hide()
          alert error
          $('.shipment_pack_select').select2('open');
          console.log error
          return
    add_pack_to_pack_list_html_ajax = ->
      pack_description = pack_select.closest('#pack_details').find('#pack_description:first').val()
      console.log 'pack description', pack_description
      $.ajax
        url: "/packs/" + pack_id
        dataType: 'script'
        data:
          pack_list_id: pack_list_id
          pack_description: pack_description
          pack_shipment_id: pack_shipment_id
        success: (data) ->
          adding_pack_spinner_icon.hide()

    if pack_id != ''
      # Only get pack info if there is a pack
      get_pack_info_ajax()
      
    return
  ### End pack selected ###