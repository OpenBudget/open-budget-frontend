define ['handlebarsRuntime'], (handlebarsRuntime) ->
  handlebarsRuntime.registerHelper "subStr", (str, start, length) ->
    str.substr start, length
