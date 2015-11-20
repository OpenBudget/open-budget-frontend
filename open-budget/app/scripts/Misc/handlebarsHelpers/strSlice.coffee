define ['handlebarsRuntime'], (handlebarsRuntime) ->
  handlebarsRuntime.registerHelper "strSlice", (str, index) ->
    str.slice index
