define ['backbone', 'scripts/modelsHelpers/BudgetItem', 'scripts/appConfig'], (Backbone, BudgetItem, appConfig) ->
  class BudgetItemKids extends Backbone.Collection

      model: BudgetItem

      initialize: (models, options) ->
          @year = options.year
          @code = options.code
          @fetch(dataType: appConfig.dataType, reset: true)

      url: ->
          "#{appConfig.baseURL}/api/budget/#{@code}/#{@year}/active-kids"

  return BudgetItemKids
