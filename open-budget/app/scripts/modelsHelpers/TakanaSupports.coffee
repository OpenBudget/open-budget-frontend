define ['backbone', 'scripts/modelsHelpers/SupportLine', 'scripts/appConfig'], (Backbone, SupportLine, appConfig) ->
  class TakanaSupports extends Backbone.Collection

      model: (attrs, options) ->
        return new SupportLine(attrs, {pageModel: options.collection.pageModel})

      comparator: (m) -> "#{m.get('year')} #{m.get('recipient')}"

      initialize: (models, options) ->
              @pageModel = options.pageModel
              @fetch(dataType: appConfig.dataType, reset: true)

      url: ->
              "#{appConfig.baseURL}/api/supports/#{@pageModel.get('budgetCode')}?limit=10000"

  return TakanaSupports;
