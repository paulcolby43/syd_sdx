# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  # Force phone format
  $("#user_phone").mask("(999) 999-9999")

  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.user_button').each ->
      $.rails.enableElement $(this)
      return
    return

  # Disable/enable sign up button on TOS check
  #$('#user_terms_of_service').click ->
  #  if $(this).is(':checked')
  #    $('#sign_up_button').removeAttr 'disabled'
  #  else
  #    $('#sign_up_button').attr 'disabled', 'disabled'
  #  return

  # Dropdown select for linking external users to customers
  #$('.portal_customers').select2 theme: 'bootstrap'
  $('.portal_customers').select2
    theme: 'bootstrap'
    minimumInputLength: 3
    ajax:
      url: '/customers'
      dataType: 'json'
      delay: 250
