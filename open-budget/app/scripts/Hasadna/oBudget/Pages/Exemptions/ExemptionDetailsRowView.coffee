define [
    "backbone",
    "Hasadna/oBudget/Pages/Exemptions/ExemptionFullDetailsView",
    "hbs!Hasadna/oBudget/Pages/Exemptions/exemption-details-row"
  ], (Backbone, ExemptionFullDetailsView, tpl_exemption_details_row) ->

  class ExemptionDetailsRowView extends Backbone.View
      events:
          'click .exemption-full-details-expander .open': 'toggleDetails'
          'click .exemption-full-details-expander .collapse': 'toggleDetails'
      tagName: 'tr'
      className: 'detailsRow'

      initialize: ->
          @initialized = false

      render: ->
          @$el.html tpl_exemption_details_row(@model)
          @$el.find('.open').show()
          @$el.find('.collapse').hide()
          @

      toggleDetails: ->
          if (!@initialized)
            @detailView = new ExemptionFullDetailsView(model: @model)
            @$el.after(@detailView.render().$el)
            @initialized = true

          @model.expanded = !@model.expanded
          if(@model.expanded)
              @$el.find('.open').hide()
              @$el.find('.collapse').show()
              @detailView.toggleShow()
          else
              @$el.find('.collapse').hide()
              @$el.find('.open').show()
              @detailView.toggleHide()

      showFullDetailsView: ->
        @$el.show()

      hideFullDetailsView: ->
        @model.expanded = false
        @$el.find('.collapse').hide()
        @$el.find('.open').show()
        if @detailView?
          @detailView.toggleHide()
        @$el.hide()
