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
                dateStr = @get 'date'
                date = dateStr.split('/')
                date = new Date(parseInt(date[2]),parseInt(date[1])-1,parseInt(date[0]))
                @set 'timestamp', date.valueOf()

class BudgetItem extends Backbone.Model

        defaults:
                net_allocated: null
                code: null
                gross_allocated: null
                title: null
                gross_revised: null
                gross_used: null
                depth: null
                net_revised: null
                year: null
                net_used: null


class ChangeLines extends Backbone.Collection

        model: ChangeLine

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @pageModel.on "change:budgetCode", => @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/changes/#{@pageModel.get('budgetCode')}"

        comparator: 'req_code'


class BudgetHistory extends Backbone.Collection

        model: BudgetItem

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @pageModel.on "change:budgetCode", => @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/budget/#{@pageModel.get('budgetCode')}"

        comparator: (m) -> m.get('year')

        getLast: -> @models[@models.length-1]



class PageModel extends Backbone.Model

        defaults:
                budgetCode: null
                baseURL: "http://the.open-budget.org.il"
                selection: [ 0, 0 ]
                currentItem: null
                dataType: "jsonp"

        initialize: ->
                @changeLines = new ChangeLines([], pageModel: @)
                @budgetHistory = new BudgetHistory([], pageModel: @)
                @budgetHistory.on 'reset', () => @set('currentItem', @budgetHistory.getLast())
                if window.location.origin == @get('baseURL')
                        @set('dataType','json')


window.models =
        ChangeLine: ChangeLine


$( ->
        window.pageModel = new PageModel()
        pageModel.set("budgetCode",window.location.hash.substring(1))
)
