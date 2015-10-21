define ['backbone', 'scripts/modelsHelpers/Participant'], (Backbone, Participant) ->

  class Participants extends Backbone.Collection
      model: Participant

      initialize: (models, options) ->
          @pageModel = options.pageModel
          @code = options.code.substring(0,4)
          @fetch(dataType: window.pageModel.get('dataType'), reset: true)

      url: ->
          "#{pageModel.get('baseURL')}/api/participants/#{@code}?limit=1000"

  return Participants
