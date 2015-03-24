class SupportList extends Backbone.View

    initialize: ->
            @pageModel = window.pageModel
            @pageModel.on 'ready-supports', => @render()

    render: ->
        if @pageModel.supports?
            jsons = _.map(@pageModel.supports.models, (x) -> x.toJSON())
            htmls = _.map(jsons, JST.single_support_item )
            for html in htmls
                @$el.append( html )

$( ->
        console.log "support_list"
        window.supportList = new SupportList({el: $("#support-lines"),model: window.pageModel});
)
