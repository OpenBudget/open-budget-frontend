window.issue_depth = (code) ->
    return code.length - 2

window.up_or_down_arrow = (allocated,revised ) ->
            if allocated > revised
                return "&#11014;"
            else
                return "&#11015;"

class BreadcrumbHeaderView extends Backbone.View
    render: ->
        @$el.html('')
        breadcrumbs = window.pageModel.breadcrumbs
        fixedBreadcrumbs = _.without(breadcrumbs, breadcrumbs[breadcrumbs.length - 2]);
        for rec in fixedBreadcrumbs
            @$el.append( window.JST.breadcrumb_item(rec))

$( ->
    if window.pageModel.get('budgetCode')?
        window.pageModel.on('ready-breadcrumbs', ->
            window.breadcrumbHeaderView = new BreadcrumbHeaderView(el: $("#header-tree"))
            window.breadcrumbHeaderView.render()
        )
)
