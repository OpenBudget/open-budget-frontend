define ['backbone'], (Backbone) ->

  class Exemption extends Backbone.Model

    initialize: (options) ->
            @pageModel = options.pageModel
            @publication_id = options.publicationId

    doFetch: ->
            @fetch(dataType: @pageModel.get('dataType'), success: @handleFetchResult)

    url: =>
            "#{@pageModel.get('baseURL')}/api/exemption/publication/#{@publication_id}"

    handleFetchResult: (collection, response) =>
            console.log response
            @trigger('ready')

