define [], () ->
  helper = (num) ->
    num ? window.format_full_number num : ''

  helper
