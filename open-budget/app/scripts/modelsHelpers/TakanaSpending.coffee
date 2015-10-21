define ['backbone', 'scripts/modelsHelpers/SpendingLine'], (backbone, SpendingLine) ->
  class TakanaSpending extends Backbone.Collection

      model: SpendingLine

      comparator: (m) -> m.get('publication_id')

      initialize: (models, options) ->
              @pageModel = options.pageModel
              @fetch(dataType: @pageModel.get('dataType'), reset: true)

      url: ->
              "#{pageModel.get('baseURL')}/api/exemption/budget/#{@pageModel.get('budgetCode')}?limit=100"

  return TakanaSpending
