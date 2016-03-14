define([
  'backbone'
  'templates/breadcrumb-item.html'
], (Backbone, template_breadcrumb_item) ->

    window.issue_depth = (code) ->
        return code.length - 2

    window.up_or_down_arrow = (allocated,revised ) ->
                if allocated > revised
                    return "&#11014;"
                else
                    return "&#11015;"

    class BreadcrumbHeaderView extends Backbone.View
        initialize: (options) ->
          @options = options

        render: ->
            @$el.html('')
            for rec in @options.breadcrumbs
                @$el.append( template_breadcrumb_item(rec))

    BreadcrumbHeaderView
)
