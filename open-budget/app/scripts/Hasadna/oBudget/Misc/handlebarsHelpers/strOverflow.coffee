define [], () ->
  helper =  (str, maxlen) ->
    if str.length > maxlen?
      str.substr(0, maxlen - 3) + "..."
    else
      str

  helper
