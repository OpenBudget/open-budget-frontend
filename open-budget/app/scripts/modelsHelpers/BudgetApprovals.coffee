define ['scripts/modelsHelpers/BudgetApproval'], (BudgetApproval) ->
  class BudgetApprovals extends Backbone.Collection
      model: BudgetApproval

      initialize: (models, options) ->
          @pageModel = options.pageModel
          @fetch(dataType: @pageModel.get('dataType'), reset: true)

      url: ->
          "#{pageModel.get('baseURL')}/api/budget/#{pageModel.get('budgetCode')}/approvals"

  return BudgetApprovals
