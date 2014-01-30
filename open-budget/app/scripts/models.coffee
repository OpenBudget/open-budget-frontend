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
                @pageModel.on "change:budgetCode", => @fetch(dataType: "jsonp",reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/changes/#{@pageModel.get('budgetCode')}"

        comparator: 'req_code'


class BudgetHistory extends Backbone.Collection

        model: BudgetItem

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @pageModel.on "change:budgetCode", => @fetch(dataType: "jsonp",reset: true)

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

        initialize: ->
                @changeLines = new ChangeLines([], pageModel: @)
                @budgetHistory = new BudgetHistory([], pageModel: @)
                @budgetHistory.on 'reset', () => @set('currentItem', @budgetHistory.getLast())


window.models =
        ChangeLine: ChangeLine


$( ->
        window.pageModel = new PageModel()
        pageModel.set("budgetCode",window.location.hash.substring(1))
)
