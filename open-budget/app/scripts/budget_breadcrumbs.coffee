class BudgetBreadcrumbsView extends Backbone.View

    render: ->
        @$el.html('')
        for rec in window.pageModel.breadcrumbs
            @$el.append( window.JST.breadcrumb_item(rec) )

$( ->
    if window.pageModel.get('budgetCode')?
        window.budgetBreadcrumbs = new BudgetBreadcrumbsView(el: $("#breadcrumb-header"))

        window.pageModel.on 'ready-breadcrumbs', ->
            window.budgetBreadcrumbs.render()
)
