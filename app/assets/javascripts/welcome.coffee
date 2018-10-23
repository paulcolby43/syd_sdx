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

  ### Start weather pieces ###
  loadWeather = (location, woeid) ->
    $.simpleWeather
      location: location
      woeid: woeid
      unit: 'f'
      success: (weather) ->
        html = '<h4><i class="weather-icon icon-' + weather.code + '"></i> ' + weather.temp + '&deg;' + weather.units.temp + '</h4>'
        html += '<div>' + weather.currently + '</div>'
        html += '<div>' + weather.city + ', ' + weather.region + '</div>'
        $('#weather').html html
        i = 0
        forecast_html = '<h4><ul class=list-inline>'
        #while i < weather.forecast.length
        while i < 2
          forecast_html += '<li>' + weather.forecast[i+1].day + ': ' + weather.forecast[i+1].high + '&deg;' + '<br>' + '<i class="weather-icon icon-' + weather.forecast[i+1].code + '"></i> </li>'
          i++
        forecast_html += '</ul></h4>'
        $('#forecast').html forecast_html
        return
      error: (error) ->
        $('#weather').html '<p>' + error + '</p>'
        $('#forecast').html '<p>' + error + '</p>'
        return
    return

  if 'geolocation' of navigator
    $('.js-geolocation').show()
  else
    $('.js-geolocation').hide()

  ### Where in the world are you? ###
  $('.js-geolocation').on 'click', ->
    navigator.geolocation.getCurrentPosition (position) ->
      loadWeather position.coords.latitude + ',' + position.coords.longitude
      #load weather using your lat/lng coordinates
      return
    return

  $(document).ready ->
    zipcode = $('#weather').data( "zipcode" )
    loadWeather zipcode, ''
    #@params location, woeid
    return
  ### End weather pieces ###