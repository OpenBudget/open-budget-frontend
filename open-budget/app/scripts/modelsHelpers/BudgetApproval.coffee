define ['backbone'], (Backbone) ->
  class BudgetApproval extends Backbone.Model
      defaults:
          year: null
          approval_date: null
          effect_date: null
          end_date: null
          approval_timestamp: null
          effect_timestamp: null
          end_timestamp: null
          link: null

      setTimestamps: ->
          @set 'approval_timestamp', dateToTimestamp(@get 'approval_date')
          @set 'effect_timestamp', dateToTimestamp(@get 'effect_date')
          @set 'end_timestamp', dateToTimestamp(@get 'end_date')

  return BudgetApproval
