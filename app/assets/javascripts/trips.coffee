# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.trip_button').each ->
      $.rails.enableElement $(this)
      return
    return

  ### File upload ###
  #$(".new_image_file").fileupload
  $(".new_task_image_file").fileupload
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
        #$(this).find('.task_pictures').prepend('<div class="row"><div class="col-xs-12 col-sm-4 col-md-4 col-lg-4"><div class="thumbnail img-responsive"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
        #$('.task_pictures').prepend('<div class="row"><div class="col-xs-12 col-sm-4 col-md-4 col-lg-4"><div class="thumbnail img-responsive"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
        #$(".picture_loading_spinner").show()
        $(this).closest('.panel').find('.task_pictures').prepend('<div class="col-xs-4 col-sm-4 col-md-4 col-lg-4"><div class="thumbnail img-responsive" style="margin-bottom: 0px;"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div>')
        $(this).closest('.panel').find(".picture_loading_spinner").show()
      else
        alert "" + file.name + " is not a gif, jpeg, or png picture file"

    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.progress-bar').css('width', progress + '%')
  ### End file upload ###

  #$('.container_select').select2 
  #  theme: 'bootstrap'
  #  minimumInputLength: 3
  #  cache: true
  #  language: noResults: ->
  #    'No results found. <a href = "/tasks/2/create_new_container?tag=" data-remote = "true" class="btn btn-primary btn-sm" type="button">Create</a>'
  #  escapeMarkup: (markup) ->
  #    markup

  $('.container_select').select2(
    theme: 'bootstrap'
    #minimumInputLength: 3
    cache: true
    #tags: true
    allowClear: true
    selectOnClose: true
    placeholder: 'Choose container'
    insertTag: (data, tag) ->
      tag.text = 'Create: ' + tag.text
      data.push tag
      return
  ).on 'select2:select', ->
    task_id = $(this).data("task-id")
    task_form = $("#task_" + task_id + "_form")
    container_number_name = $(this).find('option:selected').text()
    task_form.find('#task_container_number').val(container_number_name)
    if $(this).find('option:selected').data('select2-tag') == true # New tag/container being created
      container_number = $(this).find('option:selected').val()
      new_container_div = $("#task_" + task_id + "_create_new_container")
      #task_form = $("#task_" + task_id + "_form")
      new_container_div.find('#container_container_number').val(container_number)
      new_container_div.show()
      task_form.hide()
      #create_new_container_ajax(task_id, container_number)
    return

  $('.v2_container_select').select2(
    theme: 'bootstrap'
    minimumInputLength: 1
    ajax:
      url: '/v2/containers'
      dataType: 'json'
      delay: 250
    cache: true
    #tags: true
    allowClear: true
    selectOnClose: true
    placeholder: '-- Choose container --'
    #insertTag: (data, tag) ->
    #  tag.text = 'Create: ' + tag.text
    #  data.push tag
    #  return
  ).on 'select2:select', ->
    task_id = $(this).data("task-id")
    task_form = $("#task_" + task_id + "_form")
    container_number_name = $(this).find('option:selected').text()
    task_form.find('#task_container_number').val(container_number_name)
    if $(this).find('option:selected').data('select2-tag') == true # New tag/container being created
      container_number = $(this).find('option:selected').val()
      new_container_div = $("#task_" + task_id + "_create_new_container")
      #task_form = $("#task_" + task_id + "_form")
      new_container_div.find('#container_container_number').val(container_number)
      new_container_div.show()
      task_form.hide()
      #create_new_container_ajax(task_id, container_number)
    return

  create_new_container_ajax = (task_id, tag_number) ->
    $.ajax
      url: "/tasks/" + task_id + "/create_new_container"
      dataType: 'script'
      data:
        tag: tag_number
        
      success: (data) ->
        alert "New container created and added to task."

  # Add 'Completed' (2) option to list of task status options when adding an existing container to a task
  $('.update_task_form').submit (event) ->
    # Only add if 'Completed' (2) is not already in the list of task status options
    if $(this).closest('.tab-content').find("#task_status option[value='2']").length == 0
      $(this).closest('.tab-content').find('.task_status').append('<option value="2"> Completed </option>')
      return

  # Add 'Completed' (2) option to list of task status options when adding a new container to a task
  $('.new_container_form').submit (event) ->
    # Only add if 'Completed' (2) is not already in the list of task status options
    if $(this).closest('.tab-content').find("#task_status option[value='2']").length == 0
      $(this).closest('.tab-content').find('.task_status').append('<option value="2"> Completed </option>')
      return

  ### Remove Container ###
  $('.task_containers').on 'click', '.remove_container', (e) ->
    # User clicks on container trash button
    container_id = $(this).data("container-id")
    task_id = $(this).data("task-id")
    trash_icon = $(this).find( ".fa-trash" )
    trash_icon_spinner = $(this).find( ".fa-spinner" )
    map = $(this).closest('.task_containers').find('#task_' + task_id + '_container_map')
    location_data = $(this).closest('.containers_tab').find('.location_data')
    add_container_form = $(this).closest('.containers_tab').find('#task_' + task_id + '_form')
    
    confirm1 = confirm('Are you sure you want to remove this container?')
    if confirm1
      trash_icon_spinner.show()
      trash_icon.hide()
      e.preventDefault()
      $.ajax
        url: "/tasks/" + task_id + "/remove_container"
        dataType: 'json'
        data:
          container_id: container_id
        success: (data) ->
          trash_icon.closest('.row').remove()
          map.hide()
          location_data.hide()
          add_container_form.show()
          # Remove 'Completed' (2) option from list of task status options when removing a container from the task
          add_container_form.closest('.tab-content').find("#task_status option[value='2']").remove()
          return
        error: ->
          trash_icon_spinner.hide()
          trash_icon.show()
          alert 'Error removing container.'
          console.log 'Error removing container.'
          return
      return
  ### End Remove Container ###

  ### Task status being changed - check if all other tasks in this trip are set to complete, as well as whether previous tasks are completed. ###
  $('.task_status').on 'change', (e) ->
    input_select = $(this)
    newly_selected_value = input_select.val()
    task_form = $(this).closest('form')
    original_sequence_number = parseInt($(this).data("sequence-number")) # Get original task's sequence number and convert string to an integer for comparison
    if input_select.val() == '2' # Task is being marked complete
      all_done = true
      allow_save = true
      $(this).closest('.panel').find('.task_status').each ->
        other_sequence_number = parseInt($(this).data("sequence-number")) # Get other tasks' sequence number and convert string to an integer for comparison
        if $(this).val() != '2' # Task is not marked complete
          all_done = false
          if (other_sequence_number < original_sequence_number) && ($(this).val() != '3') # This task has a lesser sequence number than the original task, and has not been marked complete and is not void (value 3)
            allow_save = false
            alert "Task " + $(this).data("sequence-number") + " of this trip still needs to be completed!"
      if all_done == true
        $(this).data 'current-value', input_select.val() # Set the data attribute so can find previous if necessary
        # alert 'Saving all tasks as complete will complete this trip and remove it from your list.'
        confirm1 = confirm('Saving all tasks as complete will close this trip and remove it from your list. Are you sure?')
        if confirm1
          e.preventDefault()
          task_form.submit()
          $(this).closest('.modal').modal('hide')
          #$(this).closest('.modal-backdrop').remove();
          $(this).closest('.panel').remove()
          return
        else
          e.preventDefault()
          return
      else
        if allow_save == true
          $(this).data 'current-value', input_select.val() # Set the data attribute so can find previous if necessary
          task_form.submit()
          return
        else
          previous_value = $(this).data("current-value")
          $(this).val previous_value
          return
    else
      $(this).data 'current-value', input_select.val() # Set the data attribute so can find previous if necessary
      task_form.submit()
      return
  ### End Task status being changed - check if all others are set to complete ###

  $('.task_save_button').on 'click', (e) ->
    e.preventDefault()
    $(this).closest("form").find('.task_status').change()

  $('.hide_trip_icon').on 'click', ->
    # $(this).closest('.panel').remove()
    $(this).closest('.panel').hide('slow')

  ### Get User Geolocation ###
  $('.find_my_location').on 'click', (e) ->
    #output = document.getElementById('out')
    output = $(this).closest('.tab-pane').find('.location_data')[0]
    google_maps_api_key = $(this).data("google-maps-api-key")
    user_id = $(this).data("user-id")
    update_task_form = $(this).closest('.tab-pane').find('.update_task_form')
    new_container_form = $(this).closest('.tab-pane').find('.new_container_form')
    success = (position) ->
      latitude = position.coords.latitude
      longitude = position.coords.longitude
      update_task_form.find('#container_latitude').val latitude
      new_container_form.find('#container_latitude').val latitude
      update_task_form.find('#container_longitude').val longitude
      new_container_form.find('#container_longitude').val longitude
      #output.innerHTML = '<p>Latitude is ' + latitude + '° <br>Longitude is ' + longitude + '°</p>'
      output.innerHTML = ''
      img = new Image
      img.src = 'https://maps.googleapis.com/maps/api/staticmap?center=' + latitude + ',' + longitude + '&zoom=18&size=250x250&sensor=false&key=' + google_maps_api_key
      output.appendChild img
      $.ajax
        url: "/users/" + user_id + "/update_latitude_and_longitude"
        dataType: 'json'
        data:
          latitude: latitude
          longitude: longitude
        success: (data) ->
          return
        error: ->
          console.log 'Error saving location to user.'
          return
    error = ->
      output.innerHTML = 'Unable to retrieve your location'
      return

    if !navigator.geolocation
      output.innerHTML = '<p>Geolocation is not supported by your browser</p>'
      return
    output.innerHTML = '<p><i class="fa fa-spinner fa-spin"></i> Locating…</p>'
    navigator.geolocation.getCurrentPosition success, error
    return
  ### End Get User Geolocation ###

  ### Locate Container ###
  $('.task_containers').on 'click', '.locate_container', (e) ->
    confirm1 = confirm("We will drop a pin for this container where you're currently located.")
    container_id = $(this).data("container-id")
    picture_upload_button = $(this).closest('.panel').find('#container_' + container_id + '_picture_button')
    locate_button = $(this).closest('.panel').find('#container_' + container_id + '_locate_button')
    task_id = $(this).data("task-id")
    location_data = $(this).closest('.containers_tab').find('.location_data')
    
    if confirm1
      e.preventDefault()
      output = $(this).closest('.tab-pane').find('.location_data')[0]
      container_footer = $(this).closest('.panel').find('.panel-footer')[0]
      google_maps_api_key = $(this).data("google-maps-api-key")
      latitude = undefined
      longitude = undefined
      user_id = $(this).data("user-id")
      
      map_marker_icon = $(this).find( ".fa-map-marker" )
      map_marker_icon_spinner = $(this).find( ".fa-spinner" )

      map_marker_icon_spinner.show()
      map_marker_icon.hide()

      success = (position) ->
        locate_button.hide()
        map_marker_icon_spinner.hide()
        map_marker_icon.show()
        location_data.show()
        latitude = position.coords.latitude
        longitude = position.coords.longitude
        #output.innerHTML = '<p>Latitude is ' + latitude + '° <br>Longitude is ' + longitude + '°</p>'
        output.innerHTML = ''
        container_footer.innerHTML = latitude.toFixed(6) + ', ' + longitude.toFixed(6)
        img = new Image
        #img.src = 'https://maps.googleapis.com/maps/api/staticmap?center=' + latitude + ',' + longitude + '&zoom=18&size=250x250&sensor=false&key=' + google_maps_api_key
        img.src = 'https://maps.googleapis.com/maps/api/staticmap?center=' + latitude + ',' + longitude + '&zoom=19&size=260x150&sensor=false&key=' + google_maps_api_key + '&markers=color:red%7C' + latitude + ',' + longitude
        output.appendChild img
        update_container_ajax()
        update_user_ajax()
        alert "Container location saved!"
      error = ->
        map_marker_icon_spinner.hide()
        map_marker_icon.show()
        output.innerHTML = 'Unable to retrieve your location'
        return

      update_container_ajax = ->
        $.ajax
          url: "/tasks/" + task_id + "/update_container"
          dataType: 'json'
          data:
            container_id: container_id
            latitude: latitude
            longitude: longitude
          success: (data) ->
            map_marker_icon_spinner.hide()
            map_marker_icon.show()
            return
          error: ->
            map_marker_icon_spinner.hide()
            map_marker_icon.show()
            alert 'Error locating container.'
            console.log 'Error locating container.'
            return

      update_user_ajax = ->
        $.ajax
          url: "/users/" + user_id + "/update_latitude_and_longitude"
          dataType: 'json'
          data:
            latitude: latitude
            longitude: longitude
          success: (data) ->
            return
          error: ->
            console.log 'Error saving location to user.'
            return

      if !navigator.geolocation
        output.innerHTML = '<p>Geolocation is not supported by your browser</p>'
        return
      output.innerHTML = '<p><i class="fa fa-spinner fa-spin"></i> Locating…</p>'
      navigator.geolocation.getCurrentPosition success, error

      return
    else
      $(this).closest('.panel').find('.pin_image').tooltip('show')
      return
  ### End Locate Container ###

  ### Container Picture Uploads ###
  $('.task_containers').on 'click', '.container_picture_button', ->
    event_code = $(this).data( "event-code" )
    event_code_id = $(this).data( "event-code-id" )
    container_number = $(this).data( "container-number" )
    container_id = $(this).data( "container-id" )
    customer = $(this).data( "customer" )
    work_order_number = $(this).data( "work-order-number" )
    file_upload_button = $(this).closest('.panel').find('#container_' + container_id + '_file_upload_button')
    #$('#image_file_event_code_id_' + event_code_id).prop 'checked', true
    $(this).closest('.panel').find('#image_file_event_code_id').val event_code_id
    $(this).closest('.panel').find('#image_file_event_code').val event_code
    $(this).closest('.panel').find('#image_file_container_number').val container_number
    $(this).closest('.panel').find('#image_file_customer_name').val customer
    $(this).closest('.panel').find('#image_file_service_request_number').val work_order_number

    #$('input[type=file]').trigger 'click'
    file_upload_button.trigger 'click'
    return
  ### End Container Picture Uploads ###

  ### Container Picture Uploads and Store Location Meta Data ###
  $('.task_containers').on 'click', '.pin_image', ->
    # console.log 'pin image click'
    $(this).closest('.panel').find('#image_file_pin_image_location_to_container').val true
    $(this).closest('.panel').find('.container_picture_button').trigger 'click'
    return
  ### End Container Picture Uploads ###

  $('[data-toggle="tooltip"]').tooltip()


  ### Track user's location ###
  $('#track_location').on 'click', (e) ->

    x = document.getElementById('demo')

    if navigator.geolocation
      navigator.geolocation.watchPosition showPosition
    else
      x.innerHTML = 'Geolocation is not supported by this browser.'
    return

    showPosition = (position) ->
      x.innerHTML = 'Lat: ' + position.coords.latitude + '<br>Long: ' + position.coords.longitude
      console.log 'position changed'
      return

  ### Start Barcode and QR Code Scanner ###
  load_container_qrcode_scanner = ->
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
      # By passing 'undefined' for the device id parameter, the library will automatically choose the camera, preferring the main (environment facing) camera if more are available
      codeReader.decodeFromInputVideoDevice(undefined, 'video').then((result) ->
        console.log result.text
        $(this).closest('form').hide()
        #$(this).closest('form').find(".modal").modal('hide')
        #$('#qrcode_scanner_modal').modal('hide')
        #$('.shipment_pack_select').select2('open')
        #$('.shipment_pack_select').click()
        #$('.select2-search__field:first').val(result.text).trigger 'keyup'
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
  
  $('.update_task_form').on 'click', '.open_task_container_qrcode_scanner_button', (e) ->
    codeReader = new ZXing.BrowserMultiFormatReader()
    console.log 'ZXing code multi-format reader initialized'
    scanner_button = $(this)
    codeReader.getVideoInputDevices().then (videoInputDevices) ->
      firstDeviceId = videoInputDevices[0].deviceId
      # By passing 'undefined' for the device id parameter, the library will automatically choose the camera, preferring the main (environment facing) camera if more are available
      #codeReader.decodeFromInputVideoDevice(undefined, 'video').then((result) ->
      codeReader.decodeOnceFromVideoDevice(undefined, 'video_' + scanner_button.attr('id')).then((result) ->
        console.log result.text
        scanner_button.closest('form').find(".modal").modal('hide')
        scanner_button.closest('form').find(".container_select").select2('open')
        scanner_button.closest('form').find(".container_select").click()
        $('.select2-search__field:first').val(result.text).trigger('keyup')
        #$('.select2-search__field:first').trigger('change')
        #scanner_button.closest('form').find(".container_select").val(result.text);
        #scanner_button.closest('form').find(".container_select").trigger('change');
        scanner_button.closest('form').find(".container_select").select2 'close'
        codeReader.reset()
        console.log 'ZXing code reader reset'
        #scanner_button.closest('form').find(".container_select").on 'select2:select', (e) ->
        #  alert 'here'
        #  return

      scanner_button.closest('form').find(".modal").on 'hidden.bs.modal', (e) ->
        codeReader.reset()
        console.log 'ZXing code reader reset'
        return

      ).catch (err) ->
        console.error err
      console.log 'Started one time decode from camera with id ' + firstDeviceId
      return
  ### End Barcode and QR Code Scanner ###

  
