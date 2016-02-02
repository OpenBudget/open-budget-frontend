define ['backbone', 'scripts/modelsHelpers/BudgetApproval', 'scripts/appConfig'], (Backbone, BudgetApproval, appConfig) ->
  class BudgetApprovals extends Backbone.Collection
      model: BudgetApproval

      initialize: (models, options) ->
          @pageModel = options.pageModel
          @fetch(dataType: appConfig.dataType, reset: true)

      url: ->
          "#{appConfig.baseURL}/api/budget/#{@pageModel.get('budgetCode')}/approvals"

  return BudgetApprovals
