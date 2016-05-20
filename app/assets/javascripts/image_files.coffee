# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


#Required attribute fallback

attributeSupported = (attribute) ->
  attribute of document.createElement('input')

isSafariOnly = ->
  navigator.userAgent.indexOf('Safari') != -1 and navigator.userAgent.indexOf('Chrome') == -1

$ ->
  $('#new_image_file').submit ->
    if !attributeSupported('required') or isSafariOnly()
      $('#new_image_file [required]').each (index) ->
        if !$(this).val()
          alert 'Please Fill In All Required Fields.'
          return false
        return
    true
  return
# Don't allow for form submit until form fields completed
$('#new_image_file_submit').attr 'disabled', 'disabled'
# Make check if ticket number changes
$('#image_file_ticket_number').on 'change', ->
  if $('#image_file_ticket_number').val() and $('#image_file_file').val() and $('#image_file_event_code').val()
    $('#new_image_file_submit').removeAttr 'disabled'
  else
    $('#new_image_file_submit').attr 'disabled', 'disabled'
  return
# Make check if file changes
$('#image_file_file').on 'change', ->
  if $('#image_file_ticket_number').val() and $('#image_file_file').val() and $('#image_file_event_code').val()
    $('#new_image_file_submit').removeAttr 'disabled'
  else
    $('#new_image_file_submit').attr 'disabled', 'disabled'
  return
# Make check if event code changes
$('#image_file_event_code').on 'change', ->
  if $('#image_file_ticket_number').val() and $('#image_file_file').val() and $('#image_file_event_code').val()
    $('#new_image_file_submit').removeAttr 'disabled'
  else
    $('#new_image_file_submit').attr 'disabled', 'disabled'
  return