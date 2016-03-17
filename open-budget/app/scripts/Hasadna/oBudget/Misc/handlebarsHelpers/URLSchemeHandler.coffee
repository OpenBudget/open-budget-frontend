define [], () ->
  helper = (method, arg1, arg2) ->
    switch method
      when 'linkToBudget'
        window.URLSchemeHandlerInstance[method] arg1, arg2

      when 'linkToPublication'
        window.URLSchemeHandlerInstance[method] arg1, arg2

  helper
