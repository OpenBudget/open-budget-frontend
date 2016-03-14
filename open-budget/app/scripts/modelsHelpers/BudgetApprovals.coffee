define ['backbone', 'scripts/modelsHelpers/BudgetApproval', 'scripts/appConfig'], (Backbone, BudgetApproval, appConfig) ->
  class BudgetApprovals extends Backbone.Collection
      model: BudgetApproval

      initialize: (models, options) ->
          @budgetCode = options.budgetCode
          # @fetch(dataType: appConfig.dataType, reset: true)

      url: ->
          "#{appConfig.baseURL}/api/budget/#{@budgetCode}/approvals"

      fetch: ->
        super(dataType: appConfig.dataType, reset: true)

  return BudgetApprovals
