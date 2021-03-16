# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.contract_button').each ->
      $.rails.enableElement $(this)
      return
    $('.pack_list_button').each ->
      $.rails.enableElement $(this)
      return
    return

  ### Start endless page stuff ###
  loading_contracts = false
  $('a.load-more-contracts').on 'inview', (e, visible) ->
    return if loading_contracts or not visible
    loading_contracts = true
    if not $('a.load-more-contracts').is(':hidden')
      $('#more_contracts_spinner').show()
    $('a.load-more-contracts').hide()

    $.getScript $(this).attr('href'), ->
      loading_contracts = false
  ### End endless page stuff ###