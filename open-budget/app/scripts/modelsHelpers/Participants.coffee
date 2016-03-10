define ['backbone', 'scripts/modelsHelpers/Participant', 'scripts/appConfig'], (Backbone, Participant, appConfig) ->

  class Participants extends Backbone.Collection
    model: Participant

    initialize: (models, options) ->
      @options = options;
      @budgetCode = options.budgetCode.substring(0, 4)

    fetch: ->
      super(dataType: appConfig.dataType, reset: true)

    url: ->
      "#{appConfig.baseURL}/api/participants/#{@budgetCode}?limit=#{@options.limit}"

  return Participants
