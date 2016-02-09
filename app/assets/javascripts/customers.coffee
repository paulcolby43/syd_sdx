# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Start endless page stuff ###
  loading_customers = false
  $('a.load-more-customers').on 'inview', (e, visible) ->
    return if loading_customers or not visible
    loading_customers = true
    if not $('a.load-more-customers').is(':hidden')
      $('#more_customers_spinner').show()
    $('a.load-more-customers').hide()

    $.getScript $(this).attr('href'), ->
      loading_customers = false
  ### End endless page stuff ###

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.customer_button').each ->
      $.rails.enableElement $(this)
      return
    return