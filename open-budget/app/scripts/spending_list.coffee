define(['backbone',
  'scripts/models',
  'underscore',
  'templates/single-spending-item.html'
], (Backbone, models, _, tpl_single_spending_item) ->
    class SpendingList extends Backbone.View

        initialize: ->
                @pageModel = window.pageModel
                @pageModel.on 'ready-spending', => @render()

        render: ->
            if @pageModel.spending?
                jsons = _.map(@pageModel.spending.models, (x) -> x.toJSON())
                htmls = _.map(jsons, tpl_single_spending_item )
                for html in htmls
                    @$el.append( html )

    console.log "support_list"
    spendingList = new SpendingList({el: $("#spending-lines"),model: models.pageModel});
    window.spendingList = spendingList

    return spendingList
)
