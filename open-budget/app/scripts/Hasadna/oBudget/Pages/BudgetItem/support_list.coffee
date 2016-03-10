define([
  'backbone',
  'underscore',
  'templates/single-support-item.html'
], (Backbone, _, tpl_single_support_item) ->
    class SupportList extends Backbone.View

        initialize: (options) ->
          @options = options
          @supportsCollection = options.supportsCollection;
          @render()

        render: ->
            if @supportsCollection?
                jsons = _.map(@supportsCollection.models, (x) -> x.toJSON())
                htmls = _.map(jsons, tpl_single_support_item )
                for html in htmls
                    @$el.append( html )

    return SupportList
)
