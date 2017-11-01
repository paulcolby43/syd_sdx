# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.report_button').each ->
      $.rails.enableElement $(this)
      return
    return

  #$(document).on 'turbolinks:load', ->
  if $('#ticket-commodity-weight-summary-donut').length
    line_items = $('#ticket-commodity-weight-summary-donut').data('items')
    commodity_donut=Morris.Donut
      element: 'ticket-commodity-weight-summary-donut'
      data: line_items

  if $('#ticket-commodity-amount-summary-donut').length
    line_items = $('#ticket-commodity-amount-summary-donut').data('items')
    commodity_donut=Morris.Donut
      element: 'ticket-commodity-amount-summary-donut'
      data: line_items

  if $('#ticket-customer-number-summary-donut').length
    tickets = $('#ticket-customer-number-summary-donut').data('tickets')
    customer_donut=Morris.Donut
      element: 'ticket-customer-number-summary-donut'
      data: tickets

  if $('#ticket-customer-amount-summary-donut').length
    tickets = $('#ticket-customer-amount-summary-donut').data('tickets')
    customer_donut=Morris.Donut
      element: 'ticket-customer-amount-summary-donut'
      data: tickets