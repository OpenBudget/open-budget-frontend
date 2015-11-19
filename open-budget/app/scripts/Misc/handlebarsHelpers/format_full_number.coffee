define ['handlebarsRuntime'], (handlebarsRuntime) ->
  handlebarsRuntime.registerHelper "format_full_numbers", (num) ->
    num ? window.format_full_number num : ''
