# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Start endless page stuff ###
  loading_pack_contracts = false
  $('a.load-more-pack-contracts').on 'inview', (e, visible) ->
    return if loading_pack_contracts or not visible
    loading_pack_contracts = true
    if not $('a.load-more-pack-contracts').is(':hidden')
      $('#more_pack_contracts_spinner').show()
    $('a.load-more-pack-contracts').hide()

    $.getScript $(this).attr('href'), ->
      loading_pack_contracts = false
  ### End endless page stuff ###

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.pack_contract_button').each ->
      $.rails.enableElement $(this)
      return
    return