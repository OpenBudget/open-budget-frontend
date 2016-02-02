define ['backbone', 'scripts/modelsHelpers/SupportLineDescription', 'scripts/appConfig'], (Backbone, SupportLineDescription, appConfig) ->
  class SupportFieldNormalizer extends Backbone.Collection

    model: SupportLineDescription

    initialize: (models, options) ->
        @normalizationStructure = {}
        @fetch(dataType: appConfig.appType, reset: true)
        @on("reset", ->
            _json = @toJSON()
            @normalizationStructure = {}
            for fieldStructure in _json
                @normalizationStructure[fieldStructure["field"]] = fieldStructure
        )

    normalize: (field, locale) ->
      if @normalizationStructure[field]
      then @normalizationStructure[field][locale]
      else undefined

    url: ->
      "#{appConfig.baseURL}/api/describe/SupportLine"

  return SupportFieldNormalizer
