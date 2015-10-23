define ['backbone', 'scripts/modelsHelpers/SpendingLine'], (backbone, SpendingLine) ->

  class NewSpendings extends Backbone.Collection

      model: SpendingLine

      initialize: (models, options) ->
              @pageModel = options.pageModel
              @fetch(dataType: @pageModel.get('dataType'), reset: true)

      url: ->
              "#{pageModel.get('baseURL')}/api/exemption/new?limit=100"

  return NewSpendings
