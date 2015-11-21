define [
  "jquery",
  "backbone",
  "underscore",
  "vendor/moment",
  "Hasadna/oBudget/Pages/Exemptions/ControlsView",
  "Hasadna/oBudget/Pages/Exemptions/ExemptionsView",
  "Hasadna/oBudget/Pages/Exemptions/EntityDetailsView",
  "Hasadna/oBudget/Pages/Exemptions/dataHelpers",
  'Hasadna/oBudget/Pages/Exemptions/DataStruct/NewSpendings'
  ], ($, Backbone, _, moment, ControlsView, ExemptionsView, EntityDetailsView, dataHelpers, NewSpendingsCollection) ->
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
          fetchingList: false
          ministriesList: []

          controls:
            timeFrame: 7
            ministry: ''
            orderBy: 'total_flags'
            orderByDirection: -1
            freeText: ''

          exemptionsToDisplay: []

        @controlsView = new ControlsView el: "#spendings-page-article .controls", model: @uiModel
        @listenTo @controlsView, 'values', @controlsChange

        exemptionsView = new ExemptionsView
          el: "#spendings-page-article .latest-updates",
          collection: @newSpendingsCollection,
          model: @uiModel

        # Initial render
        exemptionsView.render();

        @listenTo exemptionsView, 'exemption-selected', @exemptionSelected

        entityDetails = new EntityDetailsView el: "#spendings-page-article .entity-details", model: @uiModel, baseURL: @baseURL

        @fetchList()

      exemptionSelected: (entityId, publicationId) ->
        @uiModel.set entityId: entityId, publicationId: publicationId

      controlsChange: (controlsValues) ->
        @uiModel.set 'controls', controlsValues
        @populateExemptionsToDisplay()

      fetchList: ->
        @currentFetchListRequest = @newSpendingsCollection.fetchSplit();

        @uiModel.set 'fetchingList', true

        @currentFetchListRequest.then =>
          @uiModel.set 'fetchingList', false
          @populateMinistriesList()
          @controlsView.render()

          @populateExemptionsToDisplay()

      populateMinistriesList: ->
        rawMinistriesList = @newSpendingsCollection.map (exemption) ->
          exemption.get 'publisher'

        rawMinistriesList = _.uniq rawMinistriesList

        @ministriesAliasesIndex = dataHelpers.generateAliasesIndex rawMinistriesList

        @uiModel.set 'ministriesList', Object.keys(@ministriesAliasesIndex).sort()


      populateExemptionsToDisplay: ->
        exemptionsToDisplay = @newSpendingsCollection.filter(@exemptionsFilterFunc.bind(@)).map((exemption)-> exemption.toJSON())

        exemptionsToDisplay.sort @exemptionsSortFunc.bind(@)

        exemptionsToDisplay = exemptionsToDisplay.slice(0, 300)

        @uiModel.set 'publicationId', null, silent: true
        @uiModel.set 'exemptionsToDisplay', exemptionsToDisplay

      exemptionsSortFunc: (exemption1, exemption2) ->
        controlsValues = @uiModel.get 'controls'
        ret = true

        switch controlsValues.orderBy
          when "total_flags"
            if !exemption1.flags
              exemption1.flags =
                total_flags: 0

            if !exemption2.flags
              exemption2.flags =
                total_flags: 0

          when "date"
            ret = (exemption1.last_update_date.getTime() or 0) > (exemption2.last_update_date.getTime() or 0)
          when "volume"
            ret = exemption1.volume > exemption2.volume
          else
            ret = exemption1.flags.total_flags > exemption2.flags.total_flags

        if ret
         -1 * controlsValues.orderByDirection
        else
          1 * controlsValues.orderByDirection

      exemptionsFilterFunc: (exemption) ->
        controlsValues = @uiModel.get 'controls'

        timeFrameStart = moment().subtract(controlsValues.timeFrame, 'days').valueOf()

        ret = true

        if _.isArray(controlsValues.ministry)
          if !(controlsValues.ministry.length == 1 and controlsValues.ministry[0] == "")
            # build list of possible ministreis branches
            # @todo for pref move this our of the FilterFunc that run for each exception on the list...
            localIndex = _.pick @ministriesAliasesIndex, controlsValues.ministry
            localIndex = _.values localIndex
            localIndex = _.flatten localIndex

            ret = ret and !controlsValues.ministry or localIndex.indexOf(exemption.get('publisher')) > -1

        else
          ret = ret and !controlsValues.ministry or @ministriesAliasesIndex[controlsValues.ministry].indexOf(exemption.get('publisher')) > -1

        textSearchFields = [

        ]

        # free text here, by what fields ?
        # ret = ret and !controlsValues.freeText or @freeTextFilter controlsValues.freeText, exemption

        ret = ret and exemption.get('last_update_date').getTime() > timeFrameStart

        ret


      standaloneEntity: (entityId, publicationId) ->
        @uiModel = new Backbone.Model
          entityId: entityId,
          publicationId: publicationId

        entityDetails = new EntityDetailsView el: "#entity-article", model: @uiModel, baseURL: @baseURL
