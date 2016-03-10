define ['backbone', 'scripts/modelsHelpers/SupportLine', 'scripts/appConfig'], (Backbone, SupportLine, appConfig) ->
  class TakanaSupports extends Backbone.Collection

      model: SupportLine

      _prepareModel: (attrs, options) ->
        options.supportFieldNormalizer = @options.supportFieldNormalizer
        super(attrs, options)

      comparator: (m) -> "#{m.get('year')} #{m.get('recipient')}"

      initialize: (models, options) ->
              @options = options;
              @fetch(dataType: appConfig.dataType, reset: true)

      url: ->
              "#{appConfig.baseURL}/api/supports/#{@options.budgetCode}?limit=#{@options.limit}"

  return TakanaSupports;
