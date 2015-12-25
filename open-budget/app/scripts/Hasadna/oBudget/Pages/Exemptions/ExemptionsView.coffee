define [
  'backbone',
  'hbs!Hasadna/oBudget/Pages/Exemptions/latest-spending-updates'
], (Backbone, tpl_latest_spending_updates) ->
  class ExemptionsView extends Backbone.View

    className: 'latest-updates col-sm-3'

    initialize: ->
      @listenTo @model, "change:publicationId", @exemptionSelected
      @listenTo @model, "change:exemptionsToDisplay", @render
      @listenTo @model, "change:loadingExemptions", @toggleLoading

    events:
      'click .exemption-alert:not(.selected)': 'exemptionAlertClick'
      'change select#spendings-day-limit': 'spendingsDayLimitChange'

    toggleLoading: ->
      @$el.toggleClass('loading', @model.get('loadingExemptions'))

    isMobileView: ->
      window.matchMedia('all and (max-width:768px)').matches

    exemptionAlertClick: (e) ->
      @trigger 'exemption-selected', @$el.find(e.currentTarget).data("entity-id"), @$el.find(e.currentTarget).data("publication-id")

    spendingsDayLimitChange: (e) ->
      @trigger 'days-range-change', @$el.find(e.target).val()

    exemptionSelected: ->
      @$el.find(".exemption-alert.selected").removeClass("selected")
      @$el.find(".exemption-alert[data-publication-id=#{@model.get 'publicationId'}]").addClass("selected")

    render: ->
      data =
        ui: @model.toJSON()

      @$el.html tpl_latest_spending_updates(data)

      if @model.get('publicationId') and @$el.find(".exemption-alert[data-publication-id=#{@model.get 'publicationId'}]").length
        @exemptionSelected()
      else
        if !@isMobileView()
          @$el.find(".exemption-alert:first").not('.empty').trigger("click")

  ExemptionsView
