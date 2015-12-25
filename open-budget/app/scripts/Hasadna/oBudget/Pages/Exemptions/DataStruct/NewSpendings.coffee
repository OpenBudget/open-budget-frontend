define [
  'jquery',
  'backbone',
  'Hasadna/oBudget/Pages/Exemptions/DataStruct/SpendingLine'
], ($, backbone, SpendingLine) ->

  class NewSpendings extends Backbone.Collection

    model: SpendingLine

    initialize: (models, options) ->
      @options = options

    url: ->
      "#{this.options.baseURL}/api/exemption/new/30?limit=10000"

    fetchSplit: ->
      totalLimit = 5000
      bulkSize = 1000
      reqs = _.range(totalLimit / bulkSize)
        .map( (val, index) => $.get("#{this.options.baseURL}/api/exemption/new/30?limit=#{bulkSize}&first=#{bulkSize * index}"))

      return $.when.apply(null, reqs).then(
        (args...) -> _.flatten(args.map((val) -> val[0]))
      ).then( (exemptions) => @set exemptions, parse: true)

  return NewSpendings
