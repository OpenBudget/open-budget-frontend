define [
  'underscore',
  'backbone',
  'Hasadna/oBudget/Pages/Exemptions/DataStruct/SpendingLine',
  'Hasadna/oBudget/Pages/Exemptions/dataHelpers',
  ], (_, Backbone, SpendingLine, dataHelpers) ->

  class Entity extends Backbone.Model

      defaults:
          kind: null
          name: null
          supports: []
          exemptions: []
          id: null
          exemptions_by_publisher: {}
          exemptions_sum: null

      initialize: (attrs, options) ->
        @baseURL = options.baseURL
        @entityId = options.entityId

      doFetch: ->
        @fetch(success: @handleFetchResult)

      url: ->
        "#{@baseURL}/api/entity/#{@entityId}"

      handleFetchResult: (collection, response) =>
        @supports = response.supports
        @exemptions = if response.exemptions then response.exemptions.map SpendingLine.prototype.parse else []

        @set('exemptions_sum', @get_exemptions_total_volume())

        @ministriesAliasesMap = dataHelpers.generateAliasesMap @getRawMinistriesList()

        @exemptionsByPublisherList = @exemptionsByPublisher()
        @exemptionsByMinistry = @getExemptionsByMinistry()

        @trigger('ready')

      getRawMinistriesList: ->
        _.unique @exemptions.map (exemption) -> exemption.publisher

      get_exemptions_total_volume: ->
          exemptions_sum = 0
          if @exemptions?
              for exemption in @exemptions
                  exemptions_sum += exemption.volume
          return exemptions_sum

      getExemptionsByMinistry: ->
        exemptionsByMinistry = {}

        for exemption in @exemptions
          ministry = @ministriesAliasesMap[exemption.publisher]

          if not exemptionsByMinistry[ministry]?
              exemptionsByMinistry[ministry] = publisher: ministry, exemptions: [], total_volume: 0

          exemption.ministry = ministry

          exemptionsByMinistry[ministry].exemptions.splice(0, 0, exemption)
          exemptionsByMinistry[ministry].total_volume += exemption.volume
          exemptionsByMinistry[ministry].start_date = @min_date(exemptionsByMinistry[ministry].start_date, exemption.start_date)
          exemptionsByMinistry[ministry].end_date = @max_date(exemptionsByMinistry[ministry].end_date, exemption.end_date)

        exemptionsByMinistry

      exemptionsByPublisher: ->
        exemptions_by_publisher = {}
        if @exemptions?
          for exemption in @exemptions
            if not exemptions_by_publisher[exemption.publisher]?
                exemptions_by_publisher[exemption.publisher] = {publisher: exemption.publisher, exemptions: [], total_volume: 0}
            exemptions_by_publisher[exemption.publisher].exemptions.splice(0, 0, exemption)
            exemptions_by_publisher[exemption.publisher].total_volume += exemption.volume
            exemptions_by_publisher[exemption.publisher].start_date = @min_date(exemptions_by_publisher[exemption.publisher].start_date, exemption.start_date)
            exemptions_by_publisher[exemption.publisher].end_date = @max_date(exemptions_by_publisher[exemption.publisher].end_date, exemption.end_date)

        for publisher of exemptions_by_publisher
          if (exemptions_by_publisher.hasOwnProperty(publisher))
            exemptions_by_publisher[publisher].start_date = exemptions_by_publisher[publisher].start_date
            exemptions_by_publisher[publisher].end_date = exemptions_by_publisher[publisher].end_date

        exemptions_by_publisher

      min_date: (a,b) ->
          if not a?
              return b
          if not b?
              return a
          if a.getTime() < b.getTime()
              return a
          return b

      max_date: (a,b) ->
          if not a?
              return b
          if not b?
              return a
          if a.getTime() < b.getTime()
              return b
          return a

  return Entity
