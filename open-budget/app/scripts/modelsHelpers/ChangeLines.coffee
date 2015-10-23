define ['scripts/modelsHelpers/ChangeLine'], (ChangeLine) ->
  class ChangeLines extends Backbone.Collection

      model: ChangeLine

      initialize: (models, options) ->
              @pageModel = options.pageModel
              @fetch(dataType: @pageModel.get('dataType'), reset: true)

      url: ->
              "#{pageModel.get('baseURL')}/api/changes/#{pageModel.get('budgetCode')}"

      comparator: 'req_code'

  return ChangeLines
