define ['handlebarsRuntime'], (Handlebars) ->
  Handlebars.registerHelper 'ifCond', (v1, operator, v2, options) ->
    switch operator
      when '=='
        return if v1 == v2 then options.fn(this) else options.inverse(this)
      when '==='
        return if v1 == v2 then options.fn(this) else options.inverse(this)
      when '<'
        return if v1 < v2 then options.fn(this) else options.inverse(this)
      when '<='
        return if v1 <= v2 then options.fn(this) else options.inverse(this)
      when '>'
        return if v1 > v2 then options.fn(this) else options.inverse(this)
      when '>='
        return if v1 >= v2 then options.fn(this) else options.inverse(this)
      when '&&'
        return if v1 and v2 then options.fn(this) else options.inverse(this)
      when '||'
        return if v1 or v2 then options.fn(this) else options.inverse(this)
      else
        return options.inverse(this)
    return
