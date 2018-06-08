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
  $(".new_image_file").fileupload
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
        $(this).find('.task_pictures').prepend('<div class="row"><div class="col-xs-12 col-sm-4 col-md-4 col-lg-4"><div class="thumbnail img-responsive"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
        #$('.task_pictures').prepend('<div class="row"><div class="col-xs-12 col-sm-4 col-md-4 col-lg-4"><div class="thumbnail img-responsive"><img src="' + URL.createObjectURL(data.files[0]) + '"/></div></div></div>')
        $(".picture_loading_spinner").show()
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
    minimumInputLength: 3
    cache: true
    tags: true
    allowClear: true
    placeholder: 'Search containers'
    insertTag: (data, tag) ->
      tag.text = 'Create: ' + tag.text
      data.push tag
      return
  ).on 'select2:select', ->
    if $(this).find('option:selected').data('select2-tag') == true
      task_id = $(this).data("task-id")
      container_number = $(this).find('option:selected').val()
      new_container_div = $("#task_" + task_id + "_create_new_container")
      task_form = $("#task_" + task_id + "_form")
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

  ### Remove Container ###
  $('.task_containers').on 'click', '.remove_container', (e) ->
    # User clicks on container trash button
    container_id = $(this).data("container-id")
    task_id = $(this).data("task-id")
    trash_icon = $(this).find( ".fa-trash" )
    trash_icon_spinner = $(this).find( ".fa-spinner" )
    
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
  $('.task_status').on 'change', ->
    input_select = $(this)
    newly_selected_value = input_select.val()
    task_form = $(this).closest('form')
    original_sequence_number = parseInt($(this).data("sequence-number")) # Get original task's sequence number and convert string to an integer for comparison
    if input_select.val() == '2' # Task is being marked complete
      all_done = true
      $(this).closest('.panel').find('.task_status').each ->
        other_sequence_number = parseInt($(this).data("sequence-number")) # Get other tasks' sequence number and convert string to an integer for comparison
        if $(this).val() != '2' # Task is not marked complete
          all_done = false
          if (other_sequence_number < original_sequence_number) && ($(this).val() != '3') # This task has a lesser sequence number than the original task, and has not been marked complete and is not void (value 3)
            alert "Task " + $(this).data("sequence-number") + " of this trip still needs to be completed!"
      if all_done == true
        task_form.submit()
        alert 'Saving all tasks as complete will complete this trip and remove it from your list.'
        $(this).closest('.modal').modal('hide')
        $(this).closest('.panel').remove()
      else
        task_form.submit()
        return
    else
      task_form.submit()
      return
  ### Task status being changed - check if all others are set to complete ###

  $('.hide_trip_icon').on 'click', ->
    $(this).closest('.panel').remove()

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
    e.preventDefault()
    output = $(this).closest('.tab-pane').find('.location_data')[0]
    google_maps_api_key = $(this).data("google-maps-api-key")
    latitude = undefined
    longitude = undefined

    user_id = $(this).data("user-id")
    container_id = $(this).data("container-id")
    task_id = $(this).data("task-id")
    map_marker_icon = $(this).find( ".fa-map-marker" )
    map_marker_icon_spinner = $(this).find( ".fa-spinner" )
    
    map_marker_icon_spinner.show()
    map_marker_icon.hide()

    success = (position) ->
      map_marker_icon_spinner.hide()
      map_marker_icon.show()
      latitude = position.coords.latitude
      longitude = position.coords.longitude
      #output.innerHTML = '<p>Latitude is ' + latitude + '° <br>Longitude is ' + longitude + '°</p>'
      output.innerHTML = ''
      img = new Image
      img.src = 'https://maps.googleapis.com/maps/api/staticmap?center=' + latitude + ',' + longitude + '&zoom=18&size=250x250&sensor=false&key=' + google_maps_api_key
      output.appendChild img
      update_container_ajax()
      update_user_ajax()
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
  ### End Locate Container ###