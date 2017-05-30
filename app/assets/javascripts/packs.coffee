# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Start endless page stuff ###
  loading_packs = false
  $('a.load-more-packs').on 'inview', (e, visible) ->
    return if loading_packs or not visible
    loading_packs = true
    if not $('a.load-more-packs').is(':hidden')
      $('#more_packs_spinner').show()
    $('a.load-more-packs').hide()

    $.getScript $(this).attr('href'), ->
      loading_packs = false
  ### End endless page stuff ###

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.pack_button').each ->
      $.rails.enableElement $(this)
      return
    return