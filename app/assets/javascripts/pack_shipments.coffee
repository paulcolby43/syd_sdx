# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  $(document).on 'ready page:load', ->
    # Open pack tag number search by default on page load
    $('.shipment_pack_select').select2('open')

  ### Remove pack from pack list ###
  $('#current_packs').on 'click', '.remove_pack', (e) ->
    pack_list_id = $(this).data( "pack-list-id" )
    pack_id = $(this).data( "pack-id" )
    pack_panel = $(this).closest('.panel')

    remove_pack_from_pack_list_ajax = ->
      $.ajax
        url: "/pack_lists/" + pack_list_id + "/remove_pack"
        dataType: 'json'
        data:
          pack_id: pack_id
        success: (data) ->
          pack_panel.remove()
          console.log 'Pack removed from pack list'
          return
        error: (xhr) ->
          error = $.parseJSON(xhr.responseText).error
          alert error
          console.log error
          return

    #user click on pack trash button
    confirm1 = confirm('Are you sure you want to remove this pack?')
    if confirm1
      e.preventDefault()
      remove_pack_from_pack_list_ajax()

      #trash_icon = $(this).find( ".fa-trash" )
      #trash_icon.closest('.panel').remove()
      #calculate_net_total()
      return

    else
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
  #$('.shipment_pack_select').select2
  #  theme: 'bootstrap'
  #  minimumInputLength: 3
  #  ajax:
  #    url: '/packs?status=0'
  #    dataType: 'json'
  #    delay: 250

  $('.shipment_pack_select').select2 
    theme: 'bootstrap'
    placeholder: "Tag Number",

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
          #internal_pack_number: pack_select.closest('#pack_details').find('#internal_pack_number:first').val()
          #tag_number: pack_select.closest('#pack_details').find('#tag_number:first').val()
          pack_id: pack_id
        success: (data) ->
          add_pack_to_pack_list_html_ajax()
          message = data.message
          console.log message
          if message == "More than one contract item."
            adding_pack_spinner_icon.hide()
            $('#pack_shipment_available_packs_search_form').hide()
            alert 'More than one contract item. Please select item.'
            contract_items = data.contract_items
            console.log contract_items
            $.each contract_items, (index, value) ->
              #alert index + ': ' + value['Description']
              link = $('<a/>').attr(
                href: '#'
                id: value['Id']
                class: 'add_pack_to_contract_item btn btn-default'
                'data-pack-id': pack_id
                'data-pack-list-id': pack_list_id)
              plus_sign = "<i class='fa fa-plus'></i> "
              link.html plus_sign + value['Description']
              $('#add_contract_items').append link
              $('#add_contract_items').append '</br></br>'
              return
          else
            add_pack_to_pack_list_html_ajax()
            console.log 'Pack added to pack list'
            $('.shipment_pack_select').select2('open')
          return
        error: (xhr) ->
          error = $.parseJSON(xhr.responseText).error
          adding_pack_spinner_icon.hide()
          alert error
          $('.shipment_pack_select').select2('open')
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
      #add_pack_to_pack_list_ajax()
      
    return
  ### End pack selected ###

  ### pack contract_item selected ###
  $('#pack_details').on 'click', '.add_pack_to_contract_item', ->
    adding_pack_spinner_icon = $(this).closest('#pack_details').find('.adding_pack_spinner:first')
    adding_pack_spinner_icon.show()
    pack_list_id = $(this).data( "pack-list-id" )
    pack_id = $(this).data( "pack-id" )
    contract_item_id = $(this).attr('id')

    add_pack_to_contract_item_ajax = ->
      $.ajax
        url: "/pack_lists/" + pack_list_id + "/add_pack_to_contract_item"
        dataType: 'json'
        data:
          pack_id: pack_id
          contract_item_id: contract_item_id
        success: (data) ->
          adding_pack_spinner_icon.hide()
          $('#add_contract_items').empty()
          $('#pack_shipment_available_packs_search_form').show()

    add_pack_to_contract_item_ajax()