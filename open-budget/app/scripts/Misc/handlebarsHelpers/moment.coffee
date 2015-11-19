define ['handlebarsRuntime', 'vendor/moment'], (handlebarsRuntime, momentLib) ->
  handlebarsRuntime.registerHelper "moment", (inputDateValue, format) ->
    moment = momentLib(inputDateValue)

    moment.format format

