define ['backbone', 'scripts/modelsHelpers/SpendingLine', 'scripts/appConfig'], (Backbone, SpendingLine, appConfig) ->
  class TakanaSpending extends Backbone.Collection

    model: SpendingLine

    comparator: (m) -> m.get('publication_id')

    initialize: (models, options) ->
      @options = options

    url: ->
      "#{appConfig.baseURL}/api/exemption/budget/#{@options.budgetCode}?limit=#{@options.limit}"

    fetch: ->
      super(dataType: appConfig.dataType, reset: true)

  return TakanaSpending
