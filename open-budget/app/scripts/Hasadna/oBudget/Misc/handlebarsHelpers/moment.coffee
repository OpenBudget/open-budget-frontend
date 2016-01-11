define ['vendor/moment'], (momentLib) ->

  helper = (inputDateValue, format) ->
    if inputDateValue
      moment = momentLib(inputDateValue)

      moment.format format
    else
      ''

  helper
