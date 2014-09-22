class SupportList extends Backbone.View

    initialize: ->
            @pageModel = window.pageModel
            @pageModel.on 'ready', => @render()
            console.log @el

    render: ->
        console.log 'support-list render'
        if @pageModel.takanot?
            jsons = _.map(@pageModel.takanot.models, (x) -> x.toJSON())
            console.log jsons[0]
            htmls = _.map(jsons, JST.single_support_item )
            for html in htmls
                @$el.append( html )

$( ->
        console.log "support_list"
        window.supportList = new SupportList({el: $("#support-lines"),model: window.pageModel});
)
