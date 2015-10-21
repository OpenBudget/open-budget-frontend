define ['scripts/modelsHelpers/BudgetItem'], (BudgetItem) ->
  class BudgetItemDepth extends Backbone.Collection

      model: BudgetItem

      initialize: (models, options) ->
          @pageModel = options.pageModel
          @year = options.year
          @code = options.code
          @depth = options.depth
          @fetch(dataType: @pageModel.get('dataType'), reset: true)

      url: ->
          "#{pageModel.get('baseURL')}/api/budget/#{@code}/#{@year}/depth/#{@depth}?limit=1000"

  return BudgetItemDepth;
