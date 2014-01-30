#### Models

class ChangeLineList extends Backbone.Collection
        model: window.models.ChangeLine

        initialize: (models, options) ->
                console.log 'ChangeLineList',models,options
                @pageModel = window.pageModel
                @year = options.year
                @req_id = options.req_id
                @fetch(dataType: "jsonp",reset: true)

        url: () => "#{@pageModel.get('baseURL')}/api/changes/#{@req_id}/#{@year}"

class YearlyHistoryItem extends Backbone.Model
        defaults:
                year: null
                date: null
                kind: null # 0 - budget approval, 1 - transfer
                amount: null
                amount_transferred: null
                budget_items: null
                links: null
                req_id: null

        initialize: ->
                req_id = @get('req_id')
                if req_id
                        @getBudgetItems()
                else
                        @on 'change:req_id', () => @getBudgetItems()

        getBudgetItems: ->
                @set('budget_items', new ChangeLineList([],{req_id: @get('req_id'), year: @get('year')}))  
                                        

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
                @processChangeLines()

        processChangeLines: ->
                yearlyTransfers = @pageModel.changeLines.where({ year: @get('year')})
                amount = @get('amount')
                for transfer in yearlyTransfers
                        diff = transfer.get('net_expense_diff')
                        amount += diff
                        req_id = transfer.requestId()
                        item = new YearlyHistoryItem({kind: 1, amount_transferred: diff, amount: amount, year: transfer.get('year'), date: transfer.get('date'), req_id: req_id})
                        @transferDetails.add(item)

class GlobalHistoryItems extends Backbone.Collection
        model: GlobalHistoryItem

        initialize: ->
                @pageModel = window.pageModel
                @pageModel.budgetHistory.on 'reset', () => @processBudgetHistory()

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
                @render()

        render: ->
                el = $( window.JST.year_summary( @model.toJSON() ) )
                console.log 'HistoryTableYearSummary', @el, el
                $(@el).prepend( el )
                @el = el

                                
class HistoryTableSingleTransfer extends Backbone.View

        initialize: ->
                @pageModel = window.pageModel
                @render()

        render: ->
                el = $( window.JST.single_transfer( @model.toJSON() ) )
                $(@el).after( el )
                @el = el

        addBudgetLine: (cl) ->
                el = $( window.JST.single_transfer_budget_line( cl.toJSON() ) )
                $(@el).find('.table-from').append( el )
                
             

class HistoryTableYear extends Backbone.View

        initialize: ->
                @pageModel = window.pageModel
                @transferItems = []
                @render()
                @model.get('transfer_detail').on 'add', (model) => @addTransferItem(model)
                for model in @model.get('transfer_detail').models
                        console.log 'adding explicitly'
                        @addTransferItem(model)

        render: ->
                @summaryView = new HistoryTableYearSummary({model: @model, el: @el})

        addTransferItem: (model) ->
                console.log 'addTransferItem', model, @summaryView.el, @el
                htst = new HistoryTableSingleTransfer({model: model, el: @summaryView.el})
                @transferItems.push htst
                if model.get('kind') == 1
                        model.get('budget_items').on 'reset', =>
                                for cl in model.get('budget_items').models
                                        if cl.get('budget_code') != @pageModel.get('budgetCode')
                                                htst.addBudgetLine(cl)
        

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