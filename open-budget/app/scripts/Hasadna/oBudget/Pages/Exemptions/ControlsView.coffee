define [
  'underscore',
  'backbone',
  'hbs!Hasadna/oBudget/Pages/Exemptions/controls',
  'vendor/bootstrap-select'
], (_, Backbone, tpl_controls) ->
  class ControlsView extends Backbone.View

    className: 'controls col-sm-12'

    initialize: ->
      @triggerControlsValuesDebounced = _.debounce(@triggerControlsValues.bind(@), 500);
      # @$el.on("keyup", "[name=free-text]", _.debounce(@triggerControlsValues.bind(@), 500))
      @listenTo @model, "change:publicationId", @exemptionSelected

    events:
      'change select#spendings-day-limit': 'triggerControlsValues'
      'change select.ministry': 'triggerControlsValuesDebounced'
      'change select.order-by': 'triggerControlsValues'
      'change [name=asc_desc]': 'triggerControlsValues'

    isMobile: ->
      /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent) && !chrome.webstore

    exemptionSelected: ->
      if window.matchMedia('all and (max-width:768px)').matches
        @$el.find(".controls-header").trigger("click")

    triggerControlsValues: ->
      window.setTimeout =>
        @trigger('values', @getControlsValues())
      , 0

    getControlsValues: ->
      values =
        timeFrame: @$el.find('select#spendings-day-limit').val() * 1
        ministry: @$el.find('select.ministry').val() || []
        orderBy: @$el.find('select.order-by').val()
        orderByDirection: @$el.find('[name=asc_desc]:checked').val() * 1
        # freeText: @$el.find('[name=free-text]').val()

    render: ->
      data =
        ui: @model.toJSON()

      @$el.html tpl_controls(data)

      @$el.find('select').selectpicker({
        mobile: @isMobile()
      });

  ControlsView
