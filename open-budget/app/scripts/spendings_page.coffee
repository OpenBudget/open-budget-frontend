class SpendingsPageView extends Backbone.View
    events:


    initialize: ->
        @model.on 'ready-spendings-page', =>
            @render()
        console.log 'SpendingsPageView init'

    render: ->
        @$el.css('display', 'inherit')
        data =
            exemptions: _.map(@model.newSpendings.models, (x) ->
                x.toJSON())
        @$el.html window.JST.latest_spending_updates(data)


        # Initialize the on click event of the alerts
        $("div.exemption-alert").on("click", (d) =>
            $("div.exemption-alert.selected").removeClass("selected");
            $(d.target).closest("div.exemption-alert").addClass("selected");
            @model.selectedEntity.set("selected", $(d.target).closest("div.exemption-alert").attr("supplier"))
        );

        $("div.exemption-alert:first").trigger("click")

$(->
    console.log "spendings-page"
    if window.pageModel.get("spendingsPage")?
        window.spendingsPageView = new SpendingsPageView({el: $("#spendings-page-article .latest-updates"), model: window.pageModel});
        window.entityDetails = new EntityDetailsView({el: $("#entity-details"), model: window.pageModel});
)
