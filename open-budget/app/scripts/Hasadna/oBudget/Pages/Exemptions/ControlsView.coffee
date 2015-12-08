define [
  'underscore',
  'backbone',
  'hbs!Hasadna/oBudget/Pages/Exemptions/controls'
], (_, Backbone, tpl_controls) ->
  class ControlsView extends Backbone.View

    initialize: ->
      @$el.on("keyup", "[name=free-text]", _.debounce(@triggerControlsValues.bind(@), 500))

    events:
      'change select#spendings-day-limit': 'triggerControlsValues'
      'change select.ministry': 'triggerControlsValues'
      'change select.order-by': 'triggerControlsValues'
      'change [name=asc_desc]': 'triggerControlsValues'

    triggerControlsValues: ->
      window.setTimeout =>
        @trigger('values', @getControlsValues())
      , 0

    getControlsValues: ->
      values =
        timeFrame: @$el.find('select#spendings-day-limit').val() * 1
        ministry: @$el.find('select.ministry').val()
        orderBy: @$el.find('select.order-by').val()
        orderByDirection: @$el.find('[name=asc_desc]:checked').val() * 1
        freeText: @$el.find('[name=free-text]').val()

    render: ->
      data =
        ui: @model.toJSON()

      @$el.html tpl_controls(data)


  ControlsView
