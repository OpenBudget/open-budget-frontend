define ['vendor/numbro', 'Hasadna/oBudget/Misc/numbro-he-IL'], (numbroLib) ->
  helper = (numberToFormat, params) ->

    numbro.culture "he-IL"

    number = numbroLib numberToFormat

    number[params.hash.operation] params.hash.operationFactor if params.hash.operation?

    if params.hash.isCurrency
      number.formatCurrency params.hash.format
    else
      number.format params.hash.format

  helper
