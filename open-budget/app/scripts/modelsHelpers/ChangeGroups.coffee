define ['scripts/modelsHelpers/ChangeGroup'], (ChangeGroup) ->
  class ChangeGroups extends Backbone.Collection

      model: ChangeGroup

      initialize: (models, options) ->
              @pageModel = options.pageModel
              @fetch(dataType: @pageModel.get('dataType'), reset: true)

      url: ->
              "#{pageModel.get('baseURL')}/api/changegroup/#{@pageModel.get('budgetCode')}/#{@pageModel.get('year')}/equivs?limit=1000"

  return ChangeGroups
