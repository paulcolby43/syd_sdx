# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  myOnClickEvent = ->
    alert 'hey there'
    return

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
    insertTag: (data, tag) ->
      tag.text = 'Create: ' + tag.text
      data.push tag
      return
  ).on 'select2:select', ->
    if $(this).find('option:selected').data('select2-tag') == true
      task_id = $(this).data("task-id")
      tag_number = $(this).find('option:selected').val()
      create_new_container_ajax(task_id, tag_number)
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
          trash_icon.closest('.panel').remove()
          return
        error: ->
          trash_icon_spinner.hide()
          trash_icon.show()
          alert 'Error removing container.'
          console.log 'Error removing container.'
          return
      return