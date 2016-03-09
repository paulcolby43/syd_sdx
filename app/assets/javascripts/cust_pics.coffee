# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  ### Start endless page stuff ###
  loading_images = false
  $('a.load-more-cust-pics').on 'inview', (e, visible) ->
    return if loading_images or not visible
    loading_images = true
    $('#more_images_spinner').show()
    $('a.load-more-cust-pics').hide()

    $.getScript $(this).attr('href'), ->
      loading_images = false
  ### End endless page stuff ###