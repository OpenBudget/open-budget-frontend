define ['handlebarsRuntime'], (handlebarsRuntime) ->
  handlebarsRuntime.registerHelper "URLSchemeHandler", (method, arg1, arg2) ->
    switch method
      when 'linkToBudget'
        window.URLSchemeHandlerInstance[method] arg1, arg2
