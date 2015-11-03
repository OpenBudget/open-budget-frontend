define(['backbone', 'models', 'combined_history', 'tpl!templates/single-transfer'], (Backbone, models, combinedHistory, template_single_transfer) ->
    #### Models
    class HistoryItem extends Backbone.View

            initialize: ->
                @render()
                @filled = false
                if @model.get('src') == 'changeline' and @model.get('source') != 'dummy'
                    s = @model.get('source')
                    @explanation = new window.models.ChangeExplanation(req_id: s.get('group_id'), year: s.get('year'))
                    @explanation.on 'change:explanation', =>
                        @$el.find(".transfer-list-explanation-text").html(@explanation.get('explanation').replace(/\n/g,'<br/>'))
                        @filled = true

                    @$el.on('mouseenter',   => if ! @filled then @explanation.doFetch())

            render: ->
                if @model.get('original_baseline')?
                    @$el.html( template_single_transfer( @model.toJSON() ) )

    class HistoryTable extends Backbone.View

            initialize: ->
                    @pageModel = models.pageModel
                    @model.on 'reset', => @render()

            render: ->
                    @items = []
                    for model in @model.models
                        item = new HistoryItem({model: model})
                        @items.push( item )
                        @$el.prepend( item.el )

    if models.pageModel.get('budgetCode')?
         historyTable = new HistoryTable({el: $("#change-list"),model: combinedHistory})
         window.historyTable = historyTable

    return historyTable || HistoryTable
)
