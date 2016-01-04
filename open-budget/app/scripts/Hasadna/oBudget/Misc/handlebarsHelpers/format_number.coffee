define [], () ->

  helper = (num, is_shekels = false, positive_plus=true, includeLRM = true) ->
    window.format_number num, is_shekels ,positive_plus ,includeLRM

  helper
