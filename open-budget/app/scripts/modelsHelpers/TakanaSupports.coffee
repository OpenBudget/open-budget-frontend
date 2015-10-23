define ['backbone', 'scripts/modelsHelpers/SupportLine'], (Backbone, SupportLine) ->
  class TakanaSupports extends Backbone.Collection

      model: SupportLine

      comparator: (m) -> "#{m.get('year')} #{m.get('recipient')}"

      initialize: (models, options) ->
              @pageModel = options.pageModel
              @fetch(dataType: @pageModel.get('dataType'), reset: true)

      url: ->
              "#{pageModel.get('baseURL')}/api/supports/#{@pageModel.get('budgetCode')}?limit=10000"

  return TakanaSupports;
