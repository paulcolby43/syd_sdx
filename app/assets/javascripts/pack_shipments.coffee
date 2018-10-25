# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Start endless page stuff ###
  loading_pack_shipments = false
  $('a.load-more-pack-shipments').on 'inview', (e, visible) ->
    return if loading_pack_shipments or not visible
    loading_pack_shipments = true
    if not $('a.load-more-pack-shipments').is(':hidden')
      $('#more_pack_shipments_spinner').show()
    $('a.load-more-pack-shipments').hide()

    $.getScript $(this).attr('href'), ->
      loading_pack_shipments = false
  ### End endless page stuff ###

  $(document).on 'ready page:load', ->
    # Open pack tag number search by default on page load
    $('.shipment_pack_select').select2('open')
    $('.shipment_pack_select').click()

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
          calculate_net_total()
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
  $('.shipment_pack_select').select2
    theme: 'bootstrap'
    minimumInputLength: 3
    placeholder: "Tag Number"
    ajax:
      url: '/packs?status=0'
      dataType: 'json'
  #    delay: 250

  #$('.shipment_pack_select').select2 
  #  theme: 'bootstrap'
  #  placeholder: "Tag Number"

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
          net_weight = data.net

          pack_select.closest('#pack_details').find('#internal_pack_number:first').val internal_pack_number
          pack_select.closest('#pack_details').find('#tag_number:first').val tag_number
          pack_select.closest('#pack_details').find('#pack_description:first').val name
          pack_select.closest('#pack_details').find('#pack_net_weight:first').val net_weight

          console.log 'Name', name
          console.log 'Internal Pack Number', internal_pack_number
          add_pack_to_pack_list_ajax()
          return
        error: ->
          adding_pack_spinner_icon.hide()
          #alert 'Error getting pack information.'
          console.log 'Error getting pack information.'
          return
    add_pack_to_pack_list_ajax = ->
      pack_tag_number = pack_select.closest('#pack_details').find('#tag_number:first').val()
      pack_net_weight = pack_select.closest('#pack_details').find('#pack_net_weight:first').val()
      $.ajax
        url: "/pack_lists/" + pack_list_id + "/add_pack"
        dataType: 'json'
        data:
          #internal_pack_number: pack_select.closest('#pack_details').find('#internal_pack_number:first').val()
          #tag_number: pack_select.closest('#pack_details').find('#tag_number:first').val()
          pack_id: pack_id
        success: (data) ->
          message = data.message
          console.log 'Message', message
          if message == "More than one contract item."
            ## User must choose which contract item to associate pack with ##
            adding_pack_spinner_icon.hide()
            $('#pack_shipment_available_packs_search_form').hide()
            #alert 'More than one contract item. Please select item.'
            contract_items = data.contract_items
            console.log contract_items
            $.each contract_items, (index, value) ->
              #alert index + ': ' + value['Description']
              link = $('<a/>').attr(
                href: '#'
                id: value['Id']
                class: 'add_pack_to_contract_item btn btn-default'
                'data-pack-id': pack_id
                'data-pack-tag-number': pack_tag_number
                'data-pack-net-weight': pack_net_weight
                'data-pack-list-id': pack_list_id
                'data-pack-shipment-id': pack_shipment_id
                'data-contract-item-description': value['Description'])
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
      pack_tag_number = pack_select.closest('#pack_details').find('#tag_number:first').val()
      pack_net_weight = pack_select.closest('#pack_details').find('#pack_net_weight:first').val()
      pack_list_unit_of_measure = $('#pack_list_unit_of_measure').text()
      console.log 'pack description', pack_description
      console.log 'pack list unit of measure', pack_list_unit_of_measure
      $.ajax
        url: "/packs/" + pack_id
        dataType: 'script'
        data:
          pack_list_id: pack_list_id
          pack_description: pack_description
          pack_shipment_id: pack_shipment_id
          pack_tag_number: pack_tag_number
          pack_net_weight: pack_net_weight
          pack_list_unit_of_measure: pack_list_unit_of_measure
        success: (data) ->
          adding_pack_spinner_icon.hide()
          calculate_net_total()

    if pack_id != ''
      # Only get pack info if there is a pack
      get_pack_info_ajax()
      #add_pack_to_pack_list_ajax()
      
    return
  ### End pack selected ###

  ### pack contract_item selected ###
  $('#pack_details').on 'click', '.add_pack_to_contract_item', (e) ->
    e.preventDefault()
    adding_pack_spinner_icon = $(this).closest('#pack_details').find('.adding_pack_spinner:first')
    adding_pack_spinner_icon.show()
    pack_list_id = $(this).data( "pack-list-id" )
    pack_id = $(this).data( "pack-id" )
    pack_tag_number = $(this).data( "pack-tag-number" )
    pack_net_weight = $(this).data( "pack-net-weight" )
    pack_shipment_id = $(this).data( "pack-shipment-id" )
    contract_item_id = $(this).attr('id')
    contract_item_description = $(this).data( "contract-item-description" )

    add_pack_with_contract_item_info_to_pack_list_html_ajax = ->
      $.ajax
        url: "/packs/" + pack_id
        dataType: 'script'
        data:
          pack_list_id: pack_list_id
          pack_description: contract_item_description
          pack_shipment_id: pack_shipment_id
          pack_tag_number: pack_tag_number
          pack_net_weight: pack_net_weight
        success: (data) ->
          adding_pack_spinner_icon.hide()
          calculate_net_total()

    add_pack_to_contract_item_ajax = ->
      $.ajax
        url: "/pack_lists/" + pack_list_id + "/add_pack_to_contract_item"
        dataType: 'json'
        data:
          pack_id: pack_id
          contract_item_id: contract_item_id
        success: (data) ->
          #adding_pack_spinner_icon.hide()
          add_pack_with_contract_item_info_to_pack_list_html_ajax()
          $('#add_contract_items').empty()
          $('#pack_shipment_available_packs_search_form').show()
          $('.shipment_pack_select').select2('open')

    add_pack_to_contract_item_ajax()

  calculate_net_total = ->
    sum = 0
    $('.net_weight').each ->
      sum += Number($(this).html())
      return
    $('#net_total').text sum.toFixed(2)
    return

  ### Sum all pack net weights right away ###
  $(document).on 'ready page:load', ->
    calculate_net_total()

  ### Pack shipment picture event code chosen ###
  $(".event_code_radio").on 'click', ->
    $('#upload_button').show()

  ### Start Barcode Scanner ###
  order_by_occurrence = (arr) ->
    counts = {}
    arr.forEach (value) ->
      if !counts[value]
        counts[value] = 0
      counts[value]++
      return
    Object.keys(counts).sort (curKey, nextKey) ->
      counts[curKey] < counts[nextKey]

  load_quagga = ->
    if $('#barcode-scanner').length > 0 and navigator.mediaDevices and typeof navigator.mediaDevices.getUserMedia == 'function'
      last_result = []
      if Quagga.initialized == undefined
        Quagga.onDetected (result) ->
          last_code = result.codeResult.code
          last_result.push last_code
          if last_result.length > 20
            code = order_by_occurrence(last_result)[0]
            last_result = []
            console.log code
            $('#barcode_scanner_modal').modal('hide')
            $('.shipment_pack_select').select2('open')
            $('.shipment_pack_select').click()
            $('.select2-search__field:first').val(code).trigger 'keyup'
            Quagga.stop()
            #$.ajax
            #  # type: 'POST'
            #  type: 'GET'
            #  # url: '/products/get_barcode'
            #  url: '/pack_shipments'
            #  data: upc: code
          return
      Quagga.init {
        inputStream:
          name: 'Live'
          type: 'LiveStream'
          numOfWorkers: navigator.hardwareConcurrency
          target: document.querySelector('#barcode-scanner')
        decoder: readers: [
          'ean_reader'
          'ean_8_reader'
          'code_39_reader'
          'code_39_vin_reader'
          'codabar_reader'
          'upc_reader'
          'upc_e_reader'
        ]
      }, (err) ->
        if err
          console.log err
          return
        Quagga.initialized = true
        Quagga.start()
        return
    return

  #$(document).on 'ready page:load', load_quagga
  $('#pack_details').on 'click', '#open_barcode_scanner_button', (e) ->
    load_quagga()
  
  ### End Barcode Scanner ###