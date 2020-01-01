# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.workorder_button').each ->
      $.rails.enableElement $(this)
      return
    return

  ### Start endless page stuff ###
  loading_workorders = false
  $('a.load-more-workorders').on 'inview', (e, visible) ->
    return if loading_workorders or not visible
    loading_workorders = true
    if not $('a.load-more-workorders').is(':hidden')
      $('#more_workorders_spinner').show()
    $('a.load-more-workorders').hide()

    $.getScript $(this).attr('href'), ->
      loading_workorders = false
  ### End endless page stuff ###
