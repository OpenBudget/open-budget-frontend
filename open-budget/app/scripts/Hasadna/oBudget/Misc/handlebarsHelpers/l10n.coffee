define ['Hasadna/oBudget/l10n/he-IL'], (heIl) ->

  helper = (args...) ->
    args.slice 0, args.length - 1
    .map (currenyKey) ->
      heIl[currenyKey] || 'l10n key [' + currenyKey+ '] not found'
    .join ' '

  helper
