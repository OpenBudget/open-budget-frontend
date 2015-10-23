define ['backbone', 'scripts/modelsHelpers/SupportLineDescription'], (Backbone, SupportLineDescription) ->
  class SupportFieldNormalizer extends Backbone.Collection

    model: SupportLineDescription

    initialize: (models, options) ->
        @normalizationStructure = {}
        @pageModel = options.pageModel
        @fetch(dataType: @pageModel.get('dataType'), reset: true)
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
      "#{@pageModel.get('baseURL')}/api/describe/SupportLine"

  return SupportFieldNormalizer
