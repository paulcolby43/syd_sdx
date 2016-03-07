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

  ### Start typeahead.js stuff ###
  substringMatcher = (strs) ->
    (q, cb) ->
      matches = undefined
      substrRegex = undefined
      # an array that will be populated with substring matches
      matches = []
      # regex used to determine if a string contains the substring `q`
      substrRegex = new RegExp(q, 'i')
      # iterate through the pool of strings and for any string that
      # contains the substring `q`, add it to the `matches` array
      $.each strs, (i, str) ->
        if substrRegex.test(str)
          # the typeahead jQuery plugin expects suggestions to a
          # JavaScript object, refer to typeahead docs for more info
          matches.push value: str
        return
      cb matches
      return

  # All current event codes
  event_codes = $("#image_file_event_code").data('events')
  $('#event_code .typeahead').typeahead {
    hint: true
    highlight: true
    minLength: 1
  },
    name: 'event_codes'
    displayKey: 'value'
    source: substringMatcher(event_codes)
  ### End typeahead.js stuff ###

  $('form').on 'click', '.remove_fields', (event) ->
    $(this).closest('.field').remove()
    event.preventDefault()

  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    if $('.field').length < 3
      regexp = new RegExp($(this).data('id'), 'g')
      $(this).before($(this).data('fields').replace(regexp, time))
      event.preventDefault()