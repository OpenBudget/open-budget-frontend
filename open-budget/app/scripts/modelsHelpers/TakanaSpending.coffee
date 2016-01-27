define ['backbone', 'scripts/modelsHelpers/SpendingLine', 'scripts/appConfig'], (Backbone, SpendingLine, appConfig) ->
  class TakanaSpending extends Backbone.Collection

      model: SpendingLine

      comparator: (m) -> m.get('publication_id')

      initialize: (models, options) ->
              @pageModel = options.pageModel
              @fetch(dataType: appConfig.dataType, reset: true)

      url: ->
              "#{appConfig.baseURL}/api/exemption/budget/#{@pageModel.get('budgetCode')}?limit=100"

  return TakanaSpending
