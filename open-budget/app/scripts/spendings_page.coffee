define(['backbone', 'underscore', 'models','entity_details', 'orphan_exemption_page', 'scripts/modelsHelpers/ReadyAggregator', 'tpl!templates/latest-spending-updates'], (Backbone, _, models, EntityDetailsView, OrphanExemptionView, ReadyAggregator, template_latest_spending_updates) ->
  class SpendingsPageView extends Backbone.View

        initialize: ->
          @model.newSpendings.setDaysToFetch(@model.daysLimit.get('value'))

          if @model.eventAlreadyTriggered('ready-spendings-page')
            @render()

          @model.on 'ready-spendings-page', => @render()

          @model.daysLimit.on 'change:value', =>
            @model.newSpendings.setDaysToFetch(@model.daysLimit.get('value'))
            @model.newSpendings.fetch(dataType: @model.get('dataType'), reset: true)

        events:
          'click .exemption-alert': 'exemptionAlertClick'
          'change select#spendings-day-limit': 'spendingsDayLimitChange'

        exemptionAlertClick: (e) ->
          @$el.find("div.exemption-alert.selected").removeClass("selected")
          $(e.currentTarget).addClass("selected")
          @model.selectedExemption.set("entity_id", $(e.currentTarget).attr("entity_id"))
          @model.selectedExemption.set("publication_id", $(e.currentTarget).attr("publication_id"))

          # close list on mobile
          if window.matchMedia('all and (max-width:768px)').matches
            @$el.find('button.navbar-toggle.dropdownEx').click()

        spendingsDayLimitChange: (e) ->
          @model.daysLimit.set("value", $(e.target).val())

        render: ->
          data =
              exemptions: _.map(@model.newSpendings.models, (x) ->
                  x.toJSON())
              daysLimit: @model.daysLimit.get("value")
          @$el.html template_latest_spending_updates(data)

          # disable auto select on mobile view
          if !window.matchMedia('all and (max-width:768px)').matches
            @$el.find("div.exemption-alert:first").not('.empty').trigger("click")



  if models.pageModel.get("spendingsPage")?
        window.spendingsPageView = new SpendingsPageView({el: $("#spendings-page-article .latest-updates"), model: models.pageModel});
        window.entityDetails = new EntityDetailsView({el: $("#spendings-page-article .entity-details"), model: models.pageModel});
        window.orphanExemptionPage = new OrphanExemptionView({el: $("#spendings-page-article .orphan-exemption-page"), model:models.pageModel});

  SpendingsPageView
)
