define ['backbone', 'scripts/modelsHelpers/BudgetItem'], (Backbone, BudgetItem) ->
  class BudgetItemKids extends Backbone.Collection

      model: BudgetItem

      initialize: (models, options) ->
          @pageModel = options.pageModel
          @year = options.year
          @code = options.code
          @fetch(dataType: @pageModel.get('dataType'), reset: true)

      url: ->
          "#{pageModel.get('baseURL')}/api/budget/#{@code}/#{@year}/active-kids"

  return BudgetItemKids
