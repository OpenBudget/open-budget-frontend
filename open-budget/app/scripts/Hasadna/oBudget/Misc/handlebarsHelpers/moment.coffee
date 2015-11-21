define ['handlebarsRuntime', 'vendor/moment'], (handlebarsRuntime, momentLib) ->
  handlebarsRuntime.registerHelper "moment", (inputDateValue, format) ->
    if inputDateValue
      moment = momentLib(inputDateValue)

      moment.format format
    else
      ''
