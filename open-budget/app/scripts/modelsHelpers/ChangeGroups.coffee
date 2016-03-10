define ['backbone', 'scripts/modelsHelpers/ChangeGroup', 'scripts/appConfig'], (Backbone, ChangeGroup, appConfig) ->
  class ChangeGroups extends Backbone.Collection

    model: ChangeGroup

    _prepareModel: (attrs, options) ->
      options.budgetYear = @options.budgetYear

      super(attrs, options)

      # this.constructor.__super__._prepareModel.call(@, attrs, options)

    initialize: (_models, options) ->
      @options = options

    fetch: ->
      super(dataType: appConfig.dataType, reset: true)

    url: ->
            "#{appConfig.baseURL}/api/changegroup/#{@options.budgetCode}/#{@options.budgetYear}/equivs?limit=1000"

  return ChangeGroups
