class SpendingsPageView extends Backbone.View

        initialize: ->
            @model.on 'ready-spendings-page', => @render()
            console.log 'SpendingsPageView init'

        render: ->
            @$el.css('display','inherit')
            data =
                exemptions: _.map( @model.newSpendings.models, (x) -> x.toJSON() )
            @$el.html window.JST.latest_spending_updates( data )

$( ->
        console.log "spendings-page"
        if window.pageModel.get("spendingsPage")?
            window.spendingsPageView = new SpendingsPageView({el: $("#spendings-page-article .latest-updates"),model: window.pageModel});
)
