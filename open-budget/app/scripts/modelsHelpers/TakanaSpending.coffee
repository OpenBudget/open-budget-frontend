define ['backbone', 'scripts/modelsHelpers/SpendingLine', 'scripts/appConfig'], (Backbone, SpendingLine, appConfig) ->
  class TakanaSpending extends Backbone.Collection

    model: SpendingLine

    comparator: (m) ->
      order_date = m.get('order_date').split('/')
      order_date[2] + order_date[1] + order_date[0] + ':' + m.get('order_id') + ':' + m.get('report_year') + ':' + m.get('report_period')

    initialize: (models, options) ->
      @options = options

    url: ->
      "#{appConfig.baseURL}/api/procurement/#{@options.budgetCode}?limit=10000"

    fetch: ->
      super(dataType: appConfig.dataType, reset: true)

  return TakanaSpending
