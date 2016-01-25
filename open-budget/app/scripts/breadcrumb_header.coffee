define(['backbone', 'scripts/models',
  'templates/breadcrumb-item.html'
], (Backbone, models, template_breadcrumb_item) ->

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
            for rec in breadcrumbs
                @$el.append( template_breadcrumb_item(rec))

        headerHeight: ->
          $("#affix-header").height()

    if models.pageModel.get('budgetCode')?
        models.pageModel.on('ready-breadcrumbs', ->
            window.breadcrumbHeaderView = new BreadcrumbHeaderView(el: $("#header-tree"))
            window.breadcrumbHeaderView.render()
            $("#affix-wrapper").height($("#affix-header").height())
        )

    BreadcrumbHeaderView
)
