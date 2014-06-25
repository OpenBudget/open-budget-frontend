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

# class YearlyHistoryItem extends Backbone.Model
#         defaults:
#                 year: null
#                 date: null
#                 kind: null # 0 - budget approval, 1 - transfer
#                 title: null
#                 amount: null
#                 amount_transferred: null
#                 explanation: null
#                 links: null
#                 req_id: null
#                 date_type: false
#
#         initialize: ->
#                 @pageModel = window.pageModel
#                 req_id = @get('req_id')
#                 if req_id
#                         @getExtraData()
#                 else
#                         @on 'change:req_id', () => @getExtraData()
#
#         getExtraData: ->
#                 explanation = new window.models.ChangeExplanation({req_id: @get('req_id'), year: @get('year')})
#                 explanation.doFetch()
#                 @set('explanation', explanation)
#
# class YearlyHistoryItems extends Backbone.Collection
#         model: YearlyHistoryItem
#
# class GlobalHistoryItem extends Backbone.Model
#         defaults:
#                 year: null
#                 num_transfers: null
#                 amount: null
#                 amount_transferred: null
#                 transfer_detail: null
#
#         initialize: ->
#                 @pageModel = window.pageModel
#                 @pageModel.changeLines.on 'reset', () => @processChangeLines()
#                 @transferDetails = new YearlyHistoryItems()
#                 @set('transfer_detail', @transferDetails)
#                 firstItem = new YearlyHistoryItem({kind : 0, year: @get('year'), amount: @get('amount'), amount_transferred: @get('amount')})
#                 @transferDetails.add(firstItem)
#                 @transferDetails.on 'add', () =>
#                         @set('num_transfers',@transferDetails.length-1)
#                 @processChangeLines()
#
#         processChangeLines: ->
#                 yearlyTransfers = @pageModel.changeGroups.where({ year: @get('year')})
#                 yearlyTransfers.reverse()
#                 amount = @get('amount')
#                 for transfer in yearlyTransfers
#                         diff = transfer.getCodeChanges(@pageModel.get('budgetCode')).expense_change
#                         amount += diff
#                         req_id = transfer.get('group_id')
#                         if diff?
#                                 sign = if diff<0 then -1 else 1
#                         else
#                                 sign = 0
#
#                         init_params =
#                             kind: 1
#                             amount_transferred: diff
#                             amount: amount
#                             title: transfer.get('req_titles')[0]
#                             year: @get('year')
#                             date: transfer.get('date')
#                             req_id: req_id
#                             date_type: transfer.getDateType()
#
#                         item = new YearlyHistoryItem(init_params)
#                         @transferDetails.add(item)
#
# class GlobalHistoryItems extends Backbone.Collection
#         model: GlobalHistoryItem
#
#         initialize: ->
#                 @pageModel = window.pageModel
#                 @pageModel.on 'ready', () => @processBudgetHistory()
#
#         processBudgetHistory: ->
#                 @yearlyModels = {}
#                 for model in @pageModel.budgetHistory.models
#                         ghi = new GlobalHistoryItem({year: model.get('year'), amount: model.get('net_allocated'), amount_transferred: model.get('net_revised')-model.get('net_allocated')})
#                         @yearlyModels[model.get('year')] = ghi
#                         @add(ghi)
#
# #### Views
#
# class HistoryTableYearSummary extends Backbone.View
#
#         initialize: ->
#                 @pageModel = window.pageModel
#                 el = $("<p>hello</p>")
#                 $(@el).prepend( el )
#                 @el = el
#                 @render()
#                 @delegateEvents()
#                 @model.on 'change', () => @render()
#
#         render: ->
#                 el = @el
#                 @el = $( window.JST.year_summary( @model.toJSON() ) )
#                 $(el).replaceWith(  @el )
#
# class HistoryTableSingleTransfer extends Backbone.View
#
#         initialize: ->
#                 @pageModel = window.pageModel
#                 @render()
#
#         render: ->
#                 el = $( window.JST.single_transfer( @model.toJSON() ) )
#                 $(@el).after( el )
#                 @el = el
#                 $(@el).find('.table-finance-story').click((event) -> event.preventDefault())
#
#         addExplanation: (ex) ->
#                 $(@el).find('.table-finance-story').popover({content:ex.replace(/\n/g,"<br/>"),html:true,trigger:'hover',placement:'auto',container:'#popups'})
#
#
# class HistoryTableYear extends Backbone.View
#
#         initialize: ->
#                 @pageModel = window.pageModel
#                 @transferItems = []
#                 @render()
#                 @model.get('transfer_detail').on 'add', (model) => @addTransferItem(model)
#                 transfers = @model.get('transfer_detail').models
#                 for model in transfers
#                         @addTransferItem(model)
#
#         render: ->
#                 @summaryView = new HistoryTableYearSummary({model: @model, el: @el})
#
#         addTransferItem: (model) ->
#                 if not model.get('amount_transferred')?
#                         return
#                 htst = new HistoryTableSingleTransfer({model: model, el: @summaryView.el})
#                 @transferItems.push htst
#                 if model.get('kind') == 1
#                         model.get('explanation').on 'change:explanation', =>
#                                 explanation = model.get('explanation').get('explanation')
#                                 if explanation?
#                                     htst.addExplanation(explanation)
#
#                         $(htst.el).find('.spinner').remove()

class HistoryItem extends Backbone.View

        initialize: ->
            @render()
            if @model.get('src') == 'changeline' and @model.get('source') != 'dummy'
                s = @model.get('source')
                @explanation = new window.models.ChangeExplanation(req_id: s.get('group_id'), year: s.get('year'))
                @explanation.on 'change:explanation', =>
                    @$el.find(".transfer-list-explanation-text").html(@explanation.get('explanation').replace(/\n/g,'<br/>'))
                @explanation.doFetch()

        render: ->
            @$el.html( window.JST.single_transfer( @model.toJSON() ) )

class HistoryTable extends Backbone.View

        initialize: ->
                @pageModel = window.pageModel
                @model.on 'reset', => @render()

        render: ->
                @items = []
                for model in @model.models
                    item = new HistoryItem({model: model})
                    @items.push( item )
                    @$el.prepend( item.el )

$( ->
    if window.pageModel.get('budgetCode')?
        window.historyTable = new HistoryTable({el: $("#change-list"),model: window.combinedHistory})
)
