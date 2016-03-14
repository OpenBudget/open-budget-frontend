define ['backbone', 'scripts/modelsHelpers/CompareRecord', 'scripts/appConfig'], (Backbone, CompareRecord, appConfig) ->
  class CompareRecords extends Backbone.Collection

      model: CompareRecord

      initialize: () ->

      fetch: ->
        super(dataType: appConfig.dataType, reset: true)

      url: ->
          "#{appConfig.baseURL}/api/sysprop/budget-comparisons"

      parse: (response) ->
          response.value

  return CompareRecords
