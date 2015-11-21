define [
    "backbone",
    "Hasadna/oBudget/Pages/Exemptions/ExemptionDetailsRowView",
    "hbs!Hasadna/oBudget/Pages/Exemptions/exemption-by-publisher-row"
  ], (Backbone, ExemptionDetailsRowView, tpl_exemption_by_publisher_row) ->
  class ExemptionByPublisherRowView extends Backbone.View
      events:
          'click .exemption-expander .glyphicon': 'toggleDetails'
      tagName: 'tr'
      initialize: ->
          @detailViews = []
          @initialized = false

      toggleDetails: (preselectePublicationId) ->
        selectedRow = null

        if (!@initialized)
          _.each @model.exemptions, (exemption) =>
            detailView = new ExemptionDetailsRowView(model: exemption)
            @$el.after(detailView.render().$el)
            @detailViews.push(detailView)

            if exemption.publication_id == preselectePublicationId
              selectedRow = detailView

          if selectedRow
            selectedRow.toggleDetails()
            selectedRow.el.scrollIntoView(true)

          @initialized = true

        @model.expanded = !@model.expanded
        if(@model.expanded)
            @$el.find('.open').hide()
            @$el.find('.collapse').show()
            @showAllDetailViews()
        else
            @$el.find('.open').show()
            @$el.find('.collapse').hide()
            @hideAllDetailViews()

      showAllDetailViews: ->
          _.each @detailViews, (detailView) =>
              detailView.showFullDetailsView()

      hideAllDetailViews: ->
          _.each @detailViews, (detailView) =>
              detailView.hideFullDetailsView()

      render: ->
          @$el.html tpl_exemption_by_publisher_row(@model)
          @$el.find('.collapse').hide()
          @

  ExemptionByPublisherRowView
