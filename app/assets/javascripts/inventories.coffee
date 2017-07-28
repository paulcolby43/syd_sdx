# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Start endless page stuff ###
  loading_inventories = false
  $('a.load-more-inventories').on 'inview', (e, visible) ->
    return if loading_inventories or not visible
    loading_inventories = true
    if not $('a.load-more-inventories').is(':hidden')
      $('#more_inventories_spinner').show()
    $('a.load-more-inventories').hide()

    $.getScript $(this).attr('href'), ->
      loading_inventories = false
  ### End endless page stuff ###

  $(document).on 'ready page:load', ->
    # Open pack tag number search by default on page load
    $('.inventory_pack_select').select2('open')

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.inventory_button').each ->
      $.rails.enableElement $(this)
      return
    return

  # Dropdown select for inventories packs
  $('.inventory_pack_select').select2
    theme: 'bootstrap'
    minimumInputLength: 3
    placeholder: "Tag Number"
    #language: noResults: ->
    #  '<a href=\'http://google.com\' class=\'btn btn-primary\'>Add</a>'
    #escapeMarkup: (markup) ->
    #  markup

    ajax:
      #url: '/packs?status=0'
      url: '/packs/search_by_tag_number'
      dataType: 'json'

  ### scanned pack selected ###
  $('#pack_details').on 'change', '.inventory_pack_select', ->
    pack_select = $(this)
    #pack_id = $(this).val()
    tag_number = $(this).val()
    inventory_id = $(this).data( "inventory-id" )
    #pack_list_id = $(this).data( "pack-list-id" )
    #pack_shipment_id = $(this).data( "pack-shipment-id" )
    adding_pack_spinner_icon = pack_select.closest('#pack_details').find('.adding_pack_spinner:first')
    adding_pack_spinner_icon.show()

    ### Get pack information ###
    get_pack_info_ajax = ->
      $.ajax
        #url: "/packs/" + pack_id
        url: "/packs/show_information"
        dataType: 'json'
        data: 
          tag_number: tag_number
        success: (data) ->
          message = data.message
          if message == "No pack found"
            adding_pack_spinner_icon.hide()
            #alert message
            console.log 'No pack found'
          else
            name = data.name
            internal_pack_number = data.internal_pack_number
            pack_id = data.id
            #tag_number = data.tag_number
            net_weight = data.net
            status = data.status

            pack_select.closest('#pack_details').find('#internal_pack_number:first').val internal_pack_number
            pack_select.closest('#pack_details').find('#tag_number:first').val tag_number
            pack_select.closest('#pack_details').find('#pack_description:first').val name
            pack_select.closest('#pack_details').find('#pack_net_weight:first').val net_weight
            pack_select.closest('#pack_details').find('#pack_status:first').val status

            console.log 'Name', name
            console.log 'Internal Pack Number', internal_pack_number
            add_scanned_pack_to_inventory_ajax(pack_id)
          return
        error: ->
          adding_pack_spinner_icon.hide()
          #alert 'Error getting pack information.'
          console.log 'Error getting pack information.'
          return

    ### Add scanned pack to inventory ###
    add_scanned_pack_to_inventory_ajax = (pack_id) ->
      pack_tag_number = pack_select.closest('#pack_details').find('#tag_number:first').val()
      pack_net_weight = pack_select.closest('#pack_details').find('#pack_net_weight:first').val()
      $.ajax
        url: "/inventories/" + inventory_id + "/add_scanned_pack"
        dataType: 'json'
        data:
          #internal_pack_number: pack_select.closest('#pack_details').find('#internal_pack_number:first').val()
          tag_number: pack_select.closest('#pack_details').find('#tag_number:first').val()
          pack_id: pack_id
        success: (data) ->
          adding_pack_spinner_icon.hide()
          message = data.message
          console.log 'Message', message
          if message == "Pack already scanned" 
            #alert message
          else if message == "Pack is not in closed pack list" 
            #alert message
            add_scanned_pack_to_inventory_html_ajax()
            console.log 'Pack added to inventory'
            $('.inventory_pack_select').select2('open')
          else
            add_scanned_pack_to_inventory_html_ajax()
            remove_scanned_pack_from_remaining_packs_list_html_ajax()
            console.log 'Pack added to inventory'
            $('.inventory_pack_select').select2('open')
          return
        error: ->
          adding_pack_spinner_icon.hide()
          #alert 'Error adding scanned pack to inventory.'
          console.log 'Error adding scanned pack to inventory.'
          return

    ### Add html to inventory's scanned packs list ###
    add_scanned_pack_to_inventory_html_ajax = ->
      pack_description = pack_select.closest('#pack_details').find('#pack_description:first').val()
      pack_tag_number = pack_select.closest('#pack_details').find('#tag_number:first').val()
      #pack_net_weight = pack_select.closest('#pack_details').find('#pack_net_weight:first').val()
      pack_status = pack_select.closest('#pack_details').find('#pack_status:first').val()
      console.log 'pack description', pack_description
      if pack_status == '0' # Closed pack
        $('#scanned_packs').prepend("<div class='list-group-item'>" + pack_tag_number + ' ' + pack_description + "</div>")
      else # Not a closed pack, so highlight
        $('#scanned_packs').prepend("<div class='list-group-item list-group-item-warning'>" + pack_tag_number + ' ' + pack_description + "</div>")

    ### Remove pack from remaining packs list ###
    remove_scanned_pack_from_remaining_packs_list_html_ajax = ->
      pack_tag_number = pack_select.closest('#pack_details').find('#tag_number:first').val()
      $( "#remaining_pack_" +  pack_tag_number).remove()


    get_pack_info_ajax()

  ### Edit inventory title in place ###
  # turn to inline mode
  $.fn.editable.defaults.mode = 'inline';

  # Force all elements submit via PUT method
  # $.fn.editable.defaults.ajaxOptions = {type: "put"}

  $('#inventory_title').editable
    selector: '.inventory_name'

    title: 'Update title'
    name: 'inventory'
    placeholder: 'Required'
    ajaxOptions: 
      type: 'put'
      dataType: 'json'
    validate: (value) ->
      if $.trim(value) == ''
        return 'This field is required'
      return
    success: (response, newValue) ->
      if response.status == 'error'
        return response.msg
      #msg will be shown in editable form
      return
  return
  ### End Edit inventory title in place ###