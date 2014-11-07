#### Models

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
