define ['backbone'], (Backbone) ->
  class ChangeLine extends Backbone.Model

    defaults:
            gross_expense_diff: null
            req_code: null
            committee_id: null
            allocated_income_diff: null
            personnel_max_diff: null
            explanation: null
            change_type_name: null
            net_expense_diff: null
            change_title: null
            budget_title: null
            commitment_limit_diff: null
            leading_item: null
            budget_code: null
            year: null
            date: null
            date_type: null
            req_title: null
            change_code: null
            change_type_id: null

    requestId: ->
            ret = ""+@get('req_code')
            while ret.length < 3
                    ret = "0"+ret
            ret = @get('leading_item')+'-'+ret
            while ret.length < 6
                    ret = "0"+ret
            ret

    dateType: ->
            date_type = @get('date_type')
            if date_type == 0
                ret = "approved"
            if date_type == 1
                ret = "approved-approximate"
            if date_type == 10
                ret = "pending"
            console.log 'date_type', date_type, ret
            ret

    initialize: ->
            dateStr = @get 'date'
            if dateStr?
                    @setTimestamp()
            else
                    @on 'change:date', =>
                            @setTimestamp()

    setTimestamp: ->
            @set 'timestamp', dateToTimestamp(@get 'date')

  return ChangeLine


