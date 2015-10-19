define(['backbone', 'models','entity_details'], (Backbone, models, EntityDetailsView) ->
  class SpendingsPageView extends Backbone.View

        initialize: ->
            @model.on 'ready-spendings-page', => @render()
            @model.daysLimit.on 'change:value', =>
                @model.newSpendings.fetch(dataType: @model.get('dataType'), reset: true)
                @model.readyEvents.push new ReadyAggregator("ready-spendings-page")
                                                        .addCollection(@model.newSpendings);

        render: ->
            @$el.css('display', 'inherit')
            data =
                exemptions: _.map(@model.newSpendings.models, (x) ->
                    x.toJSON())
                daysLimit: @model.daysLimit.get("value")
            @$el.html window.JST.latest_spending_updates(data)

            # Initialize the on click event of the alerts
            $("div.exemption-alert").on("click", (d) =>
                $("div.exemption-alert.selected").removeClass("selected");
                $(d.target).closest("div.exemption-alert").addClass("selected");
                @model.selectedEntity.set("selected", $(d.target).closest("div.exemption-alert").attr("supplier"))
            );

            $("div.exemption-alert:first").trigger("click")

            # Initialize the one change event of the days limit
            $("select#spendings-day-limit").on("change", (d) =>
                @model.daysLimit.set("value", $(d.target).val())
            );


  if models.pageModel.get("spendingsPage")?
        window.spendingsPageView = new SpendingsPageView({el: $("#spendings-page-article .latest-updates"), model: models.pageModel});
        window.entityDetails = new EntityDetailsView({el: $("#spendings-page-article .entity-details"), model: models.pageModel});

  SpendingsPageView
)
