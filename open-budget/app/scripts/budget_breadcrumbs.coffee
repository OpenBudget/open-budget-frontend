class BudgetBreadcrumbsView extends Backbone.View

    render: ->
        console.log "BudgetBreadcrumbsView render"
        @$el.html('')
        for rec in window.pageModel.breadcrumbs
            @$el.append( window.JST.budget_breadcrumb_element(rec) )

$( ->
    if window.pageModel.get('budgetCode')?
        window.budgetBreadcrumbs = new BudgetBreadcrumbsView(el: $("#budgetBreadcrumbs"))

        window.pageModel.on 'ready', ->
            window.budgetBreadcrumbs.render()
)
