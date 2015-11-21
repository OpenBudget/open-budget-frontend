define [
    "backbone",
    "hbs!Hasadna/oBudget/Pages/Exemptions/exemption-full-details"
  ], (Backbone, tpl_exemption_full_details) ->

  class ExemptionFullDetailsView extends Backbone.View
      tagName: 'tr'
      className: 'fullDetailsRow'

      render: ->
          @$el.html tpl_exemption_full_details(@model)
          @

      toggleShow: ->
          @$el.show("0", () =>
            @$el.find("div.exemption-full-details-div").slideDown("slow"))

      toggleHide: ->
          @$el.hide("0", () =>
            @$el.find("div.exemption-full-details-div").slideUp("slow"))
