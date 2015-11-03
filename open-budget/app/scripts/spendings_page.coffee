define(['backbone', 'underscore', 'models','entity_details', 'orphan_exemption_page'], (Backbone, _, models, EntityDetailsView, OrphanExemptionView) ->
  class SpendingsPageView extends Backbone.View

        initialize: ->
          @model.on 'ready-spendings-page', => @render()
          @model.daysLimit.on 'change:value', =>
            @model.newSpendings.fetch(dataType: @model.get('dataType'), reset: true)
            @model.readyEvents.push new ReadyAggregator("ready-spendings-page")
                                                    .addCollection(@model.newSpendings);

        events:
          'click .exemption-alert': 'exemptionAlertClick'
          'change select#spendings-day-limit': 'spendingsDayLimitChange'

        exemptionAlertClick: (e) ->
          @$el.find("div.exemption-alert.selected").removeClass("selected")
          $(e.currentTarget).addClass("selected")
          @model.selectedExemption.set("entity_id", $(e.currentTarget).attr("entity_id"))
          @model.selectedExemption.set("publication_id", $(e.currentTarget).attr("publication_id"))

        spendingsDayLimitChange: (e) ->
          @model.daysLimit.set("value", $(e.target).val())

        render: ->
          data =
              exemptions: _.map(@model.newSpendings.models, (x) ->
                  x.toJSON())
              daysLimit: @model.daysLimit.get("value")
          @$el.html window.JST.latest_spending_updates(data)
          @$el.find("div.exemption-alert:first").trigger("click")


  if models.pageModel.get("spendingsPage")?
        window.spendingsPageView = new SpendingsPageView({el: $("#spendings-page-article .latest-updates"), model: models.pageModel});
        window.entityDetails = new EntityDetailsView({el: $("#spendings-page-article .entity-details"), model: models.pageModel});
        window.orphanExemptionPage = new OrphanExemptionView({el: $("#spendings-page-article .orphan-exemption-page"), model:models.pageModel});

  SpendingsPageView
)
