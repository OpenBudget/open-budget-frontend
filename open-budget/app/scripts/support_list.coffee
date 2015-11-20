define(['backbone', 'models', 'tpl!templates/single-support-item'], (Backbone, models, tpl_single_support_item) ->
    class SupportList extends Backbone.View

        initialize: ->
                @pageModel = window.pageModel
                @pageModel.on 'ready-supports', => @render()

        render: ->
            if @pageModel.supports?
                jsons = _.map(@pageModel.supports.models, (x) -> x.toJSON())
                htmls = _.map(jsons, tpl_single_support_item )
                for html in htmls
                    @$el.append( html )

    console.log "support_list"
    supportList = new SupportList({el: $("#support-lines"),model: models.pageModel});
    window.supportList = supportList

    return supportList
)
