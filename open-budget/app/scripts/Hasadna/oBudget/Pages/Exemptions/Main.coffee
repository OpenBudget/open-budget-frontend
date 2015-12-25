define [
  "jquery",
  "backbone",
  "underscore",
  "vendor/moment",
  "Hasadna/oBudget/Pages/Exemptions/ControlsView",
  "Hasadna/oBudget/Pages/Exemptions/ExemptionsView",
  "Hasadna/oBudget/Pages/Exemptions/EntityDetailsView",
  "Hasadna/oBudget/Pages/Exemptions/dataHelpers",
  'Hasadna/oBudget/Pages/Exemptions/DataStruct/NewSpendings',
  'hbs!Hasadna/oBudget/Pages/Exemptions/initial-loader'
  ], ($, Backbone, _, moment, ControlsView, ExemptionsView, EntityDetailsView, dataHelpers, NewSpendingsCollection, tplInitialLoader) ->
    class Main extends Backbone.View

      initialize: (options) ->


      start: (options) ->
        @baseURL = options.baseURL

        $ =>
          if options.entityId
            @standaloneEntity(options.entityId, options.publicationId)
          else
            @spendingsPage()


      spendingsPage: ->
        @newSpendingsCollection = new NewSpendingsCollection [], baseURL: @baseURL

        @uiModel = new Backbone.Model
          loadingExemptions: false
          loadingEntity: false
          ministriesList: []

          controls:
            timeFrame: 7
            ministry: ''
            orderBy: 'total_flags'
            orderByDirection: -1
            freeText: ''

          exemptionsToDisplay: []

        @initialLoader = $(tplInitialLoader());
        @initialLoader.appendTo('#spendings-page-article')

        @controlsView = new ControlsView model: @uiModel
        @controlsView.$el.appendTo('#spendings-page-article')
        @listenTo @controlsView, 'values', @controlsChange

        exemptionsView = new ExemptionsView
          collection: @newSpendingsCollection,
          model: @uiModel

        exemptionsView.$el.appendTo('#spendings-page-article')

        @listenTo exemptionsView, 'exemption-selected', @exemptionSelected

        entityDetails = new EntityDetailsView model: @uiModel, baseURL: @baseURL

        entityDetails.$el.appendTo('#spendings-page-article')

        @newSpendingsCollection.fetchSplit().then () =>
          @populateMinistriesList()
          @controlsView.render()
          @populateExemptionsToDisplay()
          @initialLoader.remove();

      exemptionSelected: (entityId, publicationId) ->
        @uiModel.set entityId: entityId, publicationId: publicationId

      controlsChange: (controlsValues) ->
        @uiModel.set(controls: controlsValues, loadingExemptions: true)
        window.requestAnimationFrame =>
          window.requestAnimationFrame => @populateExemptionsToDisplay()

      populateMinistriesList: ->
        rawMinistriesList = @newSpendingsCollection.map (exemption) ->
          exemption.get 'publisher'

        rawMinistriesList = _.uniq rawMinistriesList

        @ministriesAliasesIndex = dataHelpers.generateAliasesIndex rawMinistriesList

        @uiModel.set 'ministriesList', Object.keys(@ministriesAliasesIndex).sort()


      populateExemptionsToDisplay: ->
        exemptionsToDisplay = @newSpendingsCollection
          .filter(dataHelpers.composeExemptionsFilterFunc(@uiModel.get('controls'), @ministriesAliasesIndex))
          .map((exemption)-> exemption.toJSON())

        exemptionsToDisplay.sort dataHelpers.composeExemptionsSortFunc(@uiModel.get 'controls')

        exemptionsToDisplay = exemptionsToDisplay.slice(0, 300)

        @uiModel.set 'publicationId', null, silent: true
        @uiModel.set(exemptionsToDisplay: exemptionsToDisplay, loadingExemptions: false)

      standaloneEntity: (entityId, publicationId) ->
        @uiModel = new Backbone.Model
          entityId: entityId,
          publicationId: publicationId

        entityDetails = new EntityDetailsView model: @uiModel, baseURL: @baseURL
        entityDetails.$el.removeClass('col-sm-9')
        entityDetails.$el.appendTo("#entity-article")
