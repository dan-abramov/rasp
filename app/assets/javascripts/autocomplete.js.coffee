$(document).on 'turbolinks:load', ->
  $("input[data-autocomplete]").each ->
    url = $(this).data('autocomplete')
    $(this).autocomplete
      source: url
