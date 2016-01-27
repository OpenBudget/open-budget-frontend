define([
  'backbone',
  'underscore',
  'templates/single-spending-item.html'
], (Backbone, _, tpl_single_spending_item) ->
    class SpendingList extends Backbone.View

        initialize: ->
                @model.on 'ready-spending', => @render()

        render: ->
            if @model.spending?
                jsons = _.map(@model.spending.models, (x) -> x.toJSON())
                htmls = _.map(jsons, tpl_single_spending_item )
                for html in htmls
                    @$el.append( html )

    return SpendingList
)
