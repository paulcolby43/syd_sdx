# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Start endless page stuff ###
  loading_commodities = false
  $('a.load-more-commodities').on 'inview', (e, visible) ->
    return if loading_commodities or not visible
    loading_commodities = true
    if not $('a.load-more-commodities').is(':hidden')
      $('#more_commodities_spinner').show()
    $('a.load-more-commodities').hide()

    $.getScript $(this).attr('href'), ->
      loading_commodities = false
  ### End endless page stuff ###

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.commodity_button').each ->
      $.rails.enableElement $(this)
      return
    return