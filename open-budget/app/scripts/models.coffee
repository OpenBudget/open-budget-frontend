class ChangeExplanation extends Backbone.Model

        defaults:
                year: null
                leading_item: null
                req_code: null
                req_id: null
                explanation: null

        requestId: ->
            if @get('req_id')?
                @get('req_id')
            else
                ret = ""+@get('req_code')
                while ret.length < 3
                        ret = "0"+ret
                ret = @get('leading_item')+'-'+ret
                while ret.length < 6
                        ret = "0"+ret
                ret

        doFetch: ->
                @fetch(dataType: window.pageModel.get('dataType'))

        url: () => "#{window.pageModel.get('baseURL')}/api/change_expl/#{@requestId()}/#{@get('year')}"

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
                @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/changes/#{@pageModel.get('budgetCode')}"

        comparator: 'req_code'

class ChangeGroup extends Backbone.Model

        defaults:
                req_titles: []
                transfer_ids: []
                budget_codes: []
                prefixes: []
                year: null
                date: null
                group_id: null
                changes: []
                pending: false

        initialize: (options) ->
                @pageModel = options.pageModel
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

        getCodeChanges: (code) =>
                _.filter(@get('changes'),(c)->c.budget_code==code)[0]

        getDateType: () =>
                if @get('pending') then "pending" else "approved"

        doFetch: ->
                @fetch(dataType: @pageModel.get('dataType'))

        url: ->
                "#{pageModel.get('baseURL')}/api/changegroup/#{@pageModel.get('changeGroupId')}/#{@pageModel.get('year')}"

class ChangeGroups extends Backbone.Collection

        model: ChangeGroup

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/changegroup/#{@pageModel.get('budgetCode')}?limit=1000"


class BudgetHistory extends Backbone.Collection

        model: BudgetItem

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/budget/#{@pageModel.get('budgetCode')}"

        comparator: (m) -> m.get('year')

        getLast: -> @models[@models.length-1]



class PageModel extends Backbone.Model

        defaults:
                budgetCode: null
                year: null
                changeGroupId: null
                baseURL: "http://the.open-budget.org.il"
                selection: [ 0, 0 ]
                currentItem: null
                dataType: "jsonp"
                ready: false

        initialize: ->
                if window.location.origin == @get('baseURL')
                    @set('dataType','json')
                @on 'change:budgetCode', ->
                    @changeLines = new ChangeLines([], pageModel: @)
                    @changeGroups = new ChangeGroups([], pageModel: @)
                    @budgetHistory = new BudgetHistory([], pageModel: @)
                    @budgetHistory.on 'reset',
                                      () =>
                                          @set('currentItem', @budgetHistory.getLast())
                    readyItems = [@changeLines,@changeGroups,@budgetHistory]
                    @setupReadyEvent readyItems, []
                @on 'change:changeGroupId', ->
                    @changeGroup = new ChangeGroup(pageModel: @)
                    @changeGroupExplanation = new ChangeExplanation(year: pageModel.get('year'), req_id: pageModel.get('changeGroupId'))
                    readyItems = [@changeGroup, @changeGroupExplanation]
                    @setupReadyEvent [], readyItems
                    @changeGroup.doFetch()
                    @changeGroupExplanation.doFetch()

        setupReadyEvent: (collections,models) ->
                @readyCount = collections.length + models.length
                console.log 'readyCount ',@readyCount
                for i in collections
                    i.on 'reset',() => @checkIfReady()
                for i in models
                    i.on 'change',() => @checkIfReady()

        checkIfReady: ->
            if @get('ready')
                return
            console.log 'checkIfReady ',@readyCount
            @readyCount -= 1
            if @readyCount == 0
                @set('ready',true)
                @trigger('ready')

window.models =
        ChangeLine: ChangeLine
        ChangeExplanation: ChangeExplanation


$( ->
        window.pageModel = new PageModel()
        hash = window.location.hash.substring(1)
        [kind, identifier, year] = hash.split("/",3)
        year = parseInt(year)
        console.log "hash:", kind, identifier, year
        if !isNaN(year)
            pageModel.set('year',year)
        else
            window.location.hash = "#budget/00203804/2014"
            window.location.reload()

        if kind == "budget"
            pageModel.set("budgetCode",identifier)
            $("#vis-title").html('שינויים בתקציב')
        else if kind == "transfer"
            pageModel.set("changeGroupId",identifier)
            $("#vis-title").html('פרטי העברה')
        else
            window.location.hash = "#budget/00203804/2014"
            window.location.reload()

)
