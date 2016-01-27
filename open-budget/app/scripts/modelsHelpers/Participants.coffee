define ['backbone', 'scripts/modelsHelpers/Participant', 'scripts/appConfig'], (Backbone, Participant, appConfig) ->

  class Participants extends Backbone.Collection
      model: Participant

      initialize: (models, options) ->
          @pageModel = options.pageModel
          @code = options.code.substring(0,4)
          @fetch(dataType: appConfig.dataType, reset: true)

      url: ->
          "#{appConfig.baseURL}/api/participants/#{@code}?limit=1000"

  return Participants
