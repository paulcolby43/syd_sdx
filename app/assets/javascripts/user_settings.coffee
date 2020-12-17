# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('#user_settings_event_codes').sortable update: (e, ui) ->
      #console.log $(this).sortable('serialize')
      $.ajax
        url: $(this).data('url')
        method: 'PATCH'
        data: $(this).sortable('serialize')
      return