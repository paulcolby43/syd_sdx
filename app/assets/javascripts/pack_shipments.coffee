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
    #$('.shipment_pack_select').select2('open')
    #$('.shipment_pack_select').click()

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

  # Dropdown select for shipment's pack list packs
  $('.v2_shipment_pack_select').select2
    theme: 'bootstrap'
    minimumInputLength: 3
    placeholder: "Tag Number"
    ajax:
      url: '/v2/packs?status=CLOSED'
      dataType: 'json'

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

  ### V2 pack selected ###
  $('#pack_details').on 'change', '.v2_shipment_pack_select', ->
    pack_id = $(this).val()
    pack_list_id = $(this).data( "pack-list-id" )
    pack_shipment_id = $(this).data( "pack-shipment-id" )
    pack_select = $(this)
    adding_pack_spinner_icon = pack_select.closest('#pack_details').find('.adding_pack_spinner:first')
    adding_pack_spinner_icon.show()
    get_pack_info_ajax = ->
      $.ajax
        url: "/v2/packs/" + pack_id
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
        url: "/v2/pack_lists/" + pack_list_id + "/add_pack"
        dataType: 'json'
        data:
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
            $('.v2_shipment_pack_select').select2('open')
          return
        error: (xhr) ->
          error = $.parseJSON(xhr.responseText).error
          adding_pack_spinner_icon.hide()
          alert error
          $('.v2_shipment_pack_select').select2('open')
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
        url: "/v2/packs/" + pack_id
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
  ### End V2 pack selected ###

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
  #$(".event_code_radio").on 'click', ->
  $('.shipment_file_upload_form').on 'click', '.event_code_radio', (e) ->
    $(this).closest('.modal-body').find('#upload_button').show()
    #$('#upload_button').show()

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

  load_pack_shipment_barcode_scanner = ->
    if $('#pack-barcode-scanner').length > 0 and navigator.mediaDevices and typeof navigator.mediaDevices.getUserMedia == 'function'
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
            $('#barcode_scanner_modal').modal('hide')
            $('.shipment_pack_select').select2('open')
            $('.shipment_pack_select').click()
            $('.select2-search__field:first').val(code).trigger 'keyup'
            Quagga.stop()
          return
      Quagga.init {
        inputStream:
          name: 'Live'
          type: 'LiveStream'
          numOfWorkers: navigator.hardwareConcurrency
          target: document.querySelector('#pack-barcode-scanner')
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

  $('#pack_details').on 'click', '#open_pack_barcode_scanner_button', (e) ->
    load_pack_shipment_barcode_scanner()
  ### End Barcode Scanner ###

  ### Start Barcode and QR Code Scanner ###
  load_pack_shipment_qrcode_scanner = ->
    # codeReader = new (ZXing.BrowserQRCodeReader)
    codeReader = new ZXing.BrowserMultiFormatReader()
    console.log 'ZXing code reader initialized'
    codeReader.getVideoInputDevices().then (videoInputDevices) ->
      sourceSelect = document.getElementById('sourceSelect')
      firstDeviceId = videoInputDevices[0].deviceId
      ###
      if videoInputDevices.length > 1
        videoInputDevices.forEach (element) ->
          sourceOption = document.createElement('option')
          sourceOption.text = element.label
          sourceOption.value = element.deviceId
          sourceSelect.appendChild sourceOption
          return
        sourceSelectPanel = document.getElementById('sourceSelectPanel')
        sourceSelectPanel.style.display = 'block'
      ###
      # codeReader.decodeFromInputVideoDevice(firstDeviceId, 'video').then((result) ->
      # By passing 'undefined' for the device id parameter, the library will automatically choose the camera, preferring the main (environment facing) camera if more are available
      codeReader.decodeFromInputVideoDevice(undefined, 'video').then((result) ->
        console.log result.text
        $('#qrcode_scanner_modal').modal('hide')
        $('.shipment_pack_select').select2('open')
        $('.shipment_pack_select').click()
        $('.select2-search__field:first').val(result.text).trigger 'keyup'
        codeReader.reset()
        console.log 'ZXing code reader reset'

      $('#qrcode_scanner_modal').on 'hidden.bs.modal', (e) ->
        codeReader.reset()
        console.log 'ZXing code reader reset'
        return

      ).catch (err) ->
        console.error err
      console.log 'Started continuous decode from camera with id ' + firstDeviceId
      return
  
  $('#pack_details').on 'click', '#open_pack_qrcode_scanner_button', (e) ->
    load_pack_shipment_qrcode_scanner()
  ### End Barcode and QR Code Scanner ###