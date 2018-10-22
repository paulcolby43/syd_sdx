# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.welcome_button').each ->
      $.rails.enableElement $(this)
      return
    return

  # Full screen mode
  $('#full_screen_button').on 'click', ->
    dashboard_elem = document.getElementById('kpi_dashboard')
    if dashboard_elem && dashboard_elem.requestFullscreen
      dashboard_elem.requestFullscreen()
    else if dashboard_elem && dashboard_elem.mozRequestFullScreen
      dashboard_elem.mozRequestFullScreen()
    else if dashboard_elem && dashboard_elem.webkitRequestFullscreen
      dashboard_elem.webkitRequestFullscreen()