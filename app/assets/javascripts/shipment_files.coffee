# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#Required attribute fallback

attributeSupported = (attribute) ->
  attribute of document.createElement('input')

isSafariOnly = ->
  navigator.userAgent.indexOf('Safari') != -1 and navigator.userAgent.indexOf('Chrome') == -1

$ ->
  $('#new_shipment_file').submit ->
    if !attributeSupported('required') or isSafariOnly()
      $('#new_shipment_file [required]').each (index) ->
        if !$(this).val()
          alert 'Please Fill In All Required Fields.'
          return false
        return
    true
  return
# Don't allow for form submit until form fields completed
$('#new_shipment_file_submit').attr 'disabled', 'disabled'
# Make check if ticket number changes
$('#shipment_file_ticket_number').on 'change', ->
  if $('#shipment_file_ticket_number').val() and $('#shipment_file_file').val() and $('#shipment_file_event_code').val()
    $('#new_shipment_file_submit').removeAttr 'disabled'
  else
    $('#new_shipment_file_submit').attr 'disabled', 'disabled'
  return
# Make check if file changes
$('#shipment_file_file').on 'change', ->
  if $('#shipment_file_ticket_number').val() and $('#shipment_file_file').val() and $('#shipment_file_event_code').val()
    $('#new_shipment_file_submit').removeAttr 'disabled'
  else
    $('#new_shipment_file_submit').attr 'disabled', 'disabled'
  return
# Make check if event code changes
$('#shipment_file_event_code').on 'change', ->
  if $('#shipment_file_ticket_number').val() and $('#shipment_file_file').val() and $('#shipment_file_event_code').val()
    $('#new_shipment_file_submit').removeAttr 'disabled'
  else
    $('#new_shipment_file_submit').attr 'disabled', 'disabled'
  return