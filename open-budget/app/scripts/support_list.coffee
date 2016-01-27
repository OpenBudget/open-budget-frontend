define([
  'backbone',
  'underscore',
  'templates/single-support-item.html'
], (Backbone, _, tpl_single_support_item) ->
    class SupportList extends Backbone.View

        initialize: ->
                @model.on 'ready-supports', => @render()

        render: ->
            if @model.supports?
                jsons = _.map(@model.supports.models, (x) -> x.toJSON())
                htmls = _.map(jsons, tpl_single_support_item )
                for html in htmls
                    @$el.append( html )

    return SupportList
)
