class SupportList extends Backbone.View

    initialize: ->
            @pageModel = window.pageModel
            @pageModel.on 'ready-supports', => @render()
            @renderers = $.extend($.pivotUtilities.renderers,
                    $.pivotUtilities.d3_renderers);

    render: ->
        if @pageModel.supports?
            locale = "he"
            jsons = _.map(@pageModel.supports.models, (x) -> x.toLocaleJSON(locale))
            @$el.pivotUI(jsons, {
              rows: [pageModel.supportFieldNormalizer.normalize("recipient", locale)],
              aggregatorName: "Sum",
              renderers: @renderes,
              rendererName: "Heatmap",
              vals: [pageModel.supportFieldNormalizer.normalize("amount_allocated", locale)]
            })
            @$el.find('table').attr('id', 'pivot-table');
            # @$el.find('table').addClass('table table-condensed')
            # @$el.find('select').addClass('form-control');

$( ->
        console.log "support_list"
        window.supportList = new SupportList({el: $("#support-list-content"),model: window.pageModel});
)
