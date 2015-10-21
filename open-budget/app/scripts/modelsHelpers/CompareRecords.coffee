define ['scripts/modelsHelpers/CompareRecord'], (CompareRecord) ->
  class CompareRecords extends Backbone.Collection

      model: CompareRecord

      initialize: (models, options) ->
          @pageModel = options.pageModel
          @fetch(dataType: @pageModel.get('dataType'), reset: true)

      url: ->
          "#{pageModel.get('baseURL')}/api/sysprop/budget-comparisons"

      parse: (response) ->
          response.value

  return CompareRecords
