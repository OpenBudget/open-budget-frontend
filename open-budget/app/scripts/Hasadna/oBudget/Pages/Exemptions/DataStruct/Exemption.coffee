define ['backbone', 'Hasadna/oBudget/Pages/Exemptions/DataStruct/SpendingLine'], (Backbone, SpendingLine) ->

  class Exemption extends Backbone.Model

    initialize: (attrs, options) ->
      @baseURL = options.baseURL
      @publicationId = options.publicationId

    doFetch: ->
      @fetch(success: @handleFetchResult)

    url: =>
      "#{@baseURL}/api/exemption/publication/#{@publicationId}"

    parse: SpendingLine.prototype.parse

    handleFetchResult: (collection, response) =>
      @trigger('ready')

  Exemption
