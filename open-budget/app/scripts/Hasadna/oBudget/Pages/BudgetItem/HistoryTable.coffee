define([
  'backbone',
  # 'scripts/combined_history',
  'templates/single-transfer.html',
  'scripts/modelsHelpers/ChangeExplanation'
], (Backbone, template_single_transfer, ChangeExplanation) ->
    #### Models
    class HistoryItem extends Backbone.View

            initialize: ->
                @render()
                @filled = false
                if @model.get('src') == 'changeline' and @model.get('source') != 'dummy'
                    s = @model.get('source')
                    @explanation = new ChangeExplanation(req_id: s.get('group_id'), year: s.get('year'))
                    @explanation.on 'change:explanation', =>
                        @$el.find(".transfer-list-explanation-text").html(@explanation.get('explanation').replace(/\n/g,'<br/>'))
                        @filled = true

                    @$el.on('mouseenter',   => if ! @filled then @explanation.fetch())

            render: ->
                if @model.get('original_baseline')?
                    @$el.html( template_single_transfer( @model.toJSON() ) )

    class HistoryTable extends Backbone.View

            initialize: ->
              @render()

            render: ->
                    @items = []
                    for model in @model.models
                        item = new HistoryItem({model: model})
                        @items.push( item )
                        @$el.prepend( item.el )

    return HistoryTable;
)
