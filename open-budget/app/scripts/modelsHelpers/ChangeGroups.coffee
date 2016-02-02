define ['backbone', 'scripts/modelsHelpers/ChangeGroup', 'scripts/appConfig'], (Backbone, ChangeGroup, appConfig) ->
  class ChangeGroups extends Backbone.Collection

      model: ChangeGroup

      initialize: (_models, options) ->
              @pageModel = options.pageModel
              @fetch(dataType: appConfig.dataType, reset: true)

      # pass the pageModel also to models of the collection
      _prepareModel: (attrs, options) ->
        options.pageModel = @pageModel
        # super._prepareModel(attrs, options)
        this.constructor.__super__._prepareModel.call(@, attrs, options)


      url: ->
              "#{appConfig.baseURL}/api/changegroup/#{@pageModel.get('budgetCode')}/#{@pageModel.get('year')}/equivs?limit=1000"

  return ChangeGroups
