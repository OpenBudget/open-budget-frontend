define([
  'backbone',
  'underscore',
  'templates/single-spending-item.html'
], (Backbone, _, tpl_single_spending_item) ->
    class SpendingList extends Backbone.View

        initialize: (options)->
          @options = options

        render: ->
            if @options.spending?
                jsons = _.map(@options.spending.models, (x) -> x.toJSON())
                htmls = _.map(jsons, tpl_single_spending_item)
                for html in htmls
                    @$el.append( html )

    return SpendingList
)
