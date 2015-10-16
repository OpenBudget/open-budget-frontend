define(['backbone', 'models'], (Backbone, models) ->
    class SpendingList extends Backbone.View

        initialize: ->
                @pageModel = window.pageModel
                @pageModel.on 'ready-spending', => @render()

        render: ->
            if @pageModel.spending?
                jsons = _.map(@pageModel.spending.models, (x) -> x.toJSON())
                htmls = _.map(jsons, JST.single_spending_item )
                for html in htmls
                    @$el.append( html )

    console.log "support_list"
    spendingList = new SpendingList({el: $("#spending-lines"),model: models.pageModel});
    window.spendingList = spendingList

    return spendingList
)
