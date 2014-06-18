#### Models

# class ChangeLineList extends Backbone.Collection
#         model: window.models.ChangeLine
#
#         initialize: (models, options) ->
#                 @pageModel = window.pageModel
#                 @year = options.year
#                 @req_id = options.req_id
#                 @fetch(dataType: @pageModel.get('dataType'), reset: true)
#
#         url: () => "#{@pageModel.get('baseURL')}/api/changes/#{@req_id}/#{@year}"

class ChangeExplanations extends Backbone.Collection
        model: window.models.ChangeExplanation

        initialize: (models, options) ->
                @pageModel = window.pageModel
                @year = options.year
                @req_id = options.req_id
                @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: () => "#{@pageModel.get('baseURL')}/api/change_expl/#{@req_id}/#{@year}"

class YearlyHistoryItem extends Backbone.Model
        defaults:
                year: null
                date: null
                kind: null # 0 - budget approval, 1 - transfer
                title: null
                amount: null
                amount_transferred: null
                budget_items: null
                explanation: null
                links: null
                req_id: null
                date_type: false

        initialize: ->
                @pageModel = window.pageModel
                req_id = @get('req_id')
                if req_id
                        @getExtraData()
                else
                        @on 'change:req_id', () => @getExtraData()

        getExtraData: ->
                #@set('budget_items', new ChangeLineList([],{req_id: @get('req_id'), year: @get('year')}))
                @set('explanation', new ChangeExplanations([],{req_id: @get('req_id'), year: @get('year')}))

class YearlyHistoryItems extends Backbone.Collection
        model: YearlyHistoryItem

class GlobalHistoryItem extends Backbone.Model
        defaults:
                year: null
                num_transfers: null
                amount: null
                amount_transferred: null
                transfer_detail: null

        initialize: ->
                @pageModel = window.pageModel
                @pageModel.changeLines.on 'reset', () => @processChangeLines()
                @transferDetails = new YearlyHistoryItems()
                @set('transfer_detail', @transferDetails)
                firstItem = new YearlyHistoryItem({kind : 0, year: @get('year'), amount: @get('amount'), amount_transferred: @get('amount')})
                @transferDetails.add(firstItem)
                @transferDetails.on 'add', () =>
                        @set('num_transfers',@transferDetails.length-1)
                @processChangeLines()

        processChangeLines: ->
                yearlyTransfers = @pageModel.changeGroups.where({ year: @get('year')})
                amount = @get('amount')
                for transfer in yearlyTransfers
                        diff = transfer.getCodeChanges(@pageModel.get('budgetCode')).expense_change
                        amount += diff
                        req_id = transfer.get('group_id')
                        if diff?
                                sign = if diff<0 then -1 else 1
                        else
                                sign = 0
                        budget_items = transfer.get('changes')
                        budget_items = _.filter(budget_items, (m) -> m.expense_change != 0 )
                        budget_items = _.sortBy(budget_items,(m) -> m.budget_code.length)
                        budget_items = _.sortBy(budget_items, (m) -> sign*m.expense_change)
                        budget_items = _.filter(budget_items, (m) -> (sign*m.expense_change) < 0)
                        #budget_items = _.filter(budget_items, (m) -> m.budget_code != @pageModel.get('budgetCode'))
                        selected_budget_items = [@pageModel.get('budgetCode')]
                        budget_items = _.filter(budget_items,
                                                (m) ->
                                                    for x in selected_budget_items
                                                        if m.budget_code.indexOf(x) == 0
                                                             return false
                                                    selected_budget_items.push(m.budget_code)
                                                    true
                                                )
                        budget_items = budget_items[0..2]

                        init_params =
                            kind: 1
                            amount_transferred: diff
                            amount: amount
                            title: transfer.get('req_titles')[0]
                            year: @get('year')
                            date: transfer.get('date')
                            req_id: req_id
                            date_type: transfer.getDateType()
                            budget_items: budget_items

                        item = new YearlyHistoryItem(init_params)
                        @transferDetails.add(item)

class GlobalHistoryItems extends Backbone.Collection
        model: GlobalHistoryItem

        initialize: ->
                @pageModel = window.pageModel
                @pageModel.on 'ready', () => @processBudgetHistory()

        processBudgetHistory: ->
                @yearlyModels = {}
                for model in @pageModel.budgetHistory.models
                        ghi = new GlobalHistoryItem({year: model.get('year'), amount: model.get('net_allocated'), amount_transferred: model.get('net_revised')-model.get('net_allocated')})
                        @yearlyModels[model.get('year')] = ghi
                        @add(ghi)

#### Views

class HistoryTableYearSummary extends Backbone.View

        initialize: ->
                @pageModel = window.pageModel
                el = $("<p>hello</p>")
                $(@el).prepend( el )
                @el = el
                @render()
                @delegateEvents()
                @model.on 'change', () => @render()

        render: ->
                el = @el
                @el = $( window.JST.year_summary( @model.toJSON() ) )
                $(el).replaceWith(  @el )
                $(@el).find('.table-date').click( () => @updateRowVisibility() )

        updateRowVisibility: ->
                year = @model.get('year')
                $(".history-table tbody tr").each( ->
                        row = $(@)
                        row_year = parseInt(row.attr('data-year'))
                        if (row.hasClass('table-single-transfer') or row.hasClass('table-yearly-budget'))
                                if (year != row_year)
                                        row.toggleClass('active',false)
                                        row.find('td > div').css('height',0)
                                        row.find('td > div').css('padding',0)
                                else
                                        row.toggleClass('active',true)
                                        row.find('td > div').css('height','auto')
                                        row.find('td > div').css('padding','10px 0')
                        )
                window.setTimeout(  () =>
                                        $('html, body').animate({ scrollTop: $(@el).position().top  },1000);#                                         $(@el)[0].scrollIntoView()
                                  ,
                                    1000)


class HistoryTableSingleTransfer extends Backbone.View

        initialize: ->
                @pageModel = window.pageModel
                @render()

        render: ->
                el = $( window.JST.single_transfer( @model.toJSON() ) )
                $(@el).after( el )
                @el = el
                $(@el).find('.table-finance-story').click((event) -> event.preventDefault())

        addBudgetLine: (cl) ->
                el = $( window.JST.single_transfer_budget_line( cl ) )
                $(@el).find('.budget-lines').append( el )

        addExplanation: (ex) ->
                $(@el).find('.table-finance-story').popover({content:ex.get("explanation").replace(/\n/g,"<br/>"),html:true,trigger:'hover',placement:'auto',container:'#popups'})


class HistoryTableYear extends Backbone.View

        initialize: ->
                @pageModel = window.pageModel
                @transferItems = []
                @render()
                @model.get('transfer_detail').on 'add', (model) => @addTransferItem(model)
                transfers = @model.get('transfer_detail').models
                for model in transfers
                        @addTransferItem(model)

        render: ->
                @summaryView = new HistoryTableYearSummary({model: @model, el: @el})

        addTransferItem: (model) ->
                if ((model.get('kind') == 1) and (model.get('amount_transferred') == 0))
                        return
                if not model.get('amount_transferred')?
                        return
                htst = new HistoryTableSingleTransfer({model: model, el: @summaryView.el})
                @transferItems.push htst
                if model.get('kind') == 1
                        model.get('explanation').on 'reset', =>
                                 explanation = model.get('explanation').models[0]
                                 if explanation?
                                     htst.addExplanation(explanation)

                        $(htst.el).find('.spinner').remove()
                        for bl in model.get('budget_items')
                            htst.addBudgetLine(bl)


class HistoryTable extends Backbone.View

        initialize: ->
                @pageModel = window.pageModel
                @globalHistoryItems = new GlobalHistoryItems()
                @globalHistoryItems.on 'add', (model) => @addYearPanel(model)
                @subViews = {}
                @render()

        addYearPanel: (globalHistoryItem) ->
                year = globalHistoryItem.get('year')
                yearView = new HistoryTableYear({model: globalHistoryItem, el: @$('tbody')})
                @subViews[year] = yearView

        render: ->
                $(@el).html( window.JST.history_table() )

$( ->
        window.historyTable = new HistoryTable({el: $("#change-list")})
)
