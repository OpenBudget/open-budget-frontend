define ['backbone', 'scripts/modelsHelpers/BudgetItem'], (backbone, BudgetItem) ->

  class BudgetHistory extends Backbone.Collection

      model: BudgetItem

      initialize: (models, options) ->
              @pageModel = options.pageModel
              @fetch(dataType: @pageModel.get('dataType'), reset: true)

      url: ->
              "#{pageModel.get('baseURL')}/api/budget/#{@pageModel.get('budgetCode')}/#{@pageModel.get('year')}/equivs"

      comparator: (m) -> m.get('year')

      getLast: -> @models[@models.length-1]

  return BudgetHistory
