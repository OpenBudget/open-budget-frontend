define [], () ->
  helper = (str, start, length) ->
    str.substr start, length

  helper
