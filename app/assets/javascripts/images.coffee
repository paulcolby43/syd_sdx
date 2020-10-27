# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  ### Start endless page stuff ###
  loading_images = false
  $('a.load-more-images').on 'inview', (e, visible) ->
    return if loading_images or not visible
    loading_images = true
    if not $('a.load-more-images').is(':hidden')
      $('#more_images_spinner').show()
    $('a.load-more-images').hide()

    $.getScript $(this).attr('href'), ->
      loading_images = false
  ### End endless page stuff ###

  $('form').on 'click', '.remove_fields', (event) ->
    $(this).closest('.field').remove()
    event.preventDefault()

  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    if $('.field').length < 3
      regexp = new RegExp($(this).data('id'), 'g')
      $(this).before($(this).data('fields').replace(regexp, time))
      event.preventDefault()

  $('#column_select').on 'change', '#column', ->
    column_name = $(this).val()
    $('#' + column_name + '_form_group').show();
    