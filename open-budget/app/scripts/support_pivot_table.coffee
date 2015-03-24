class SupporPivotTable extends Backbone.View

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
            });

$( ->
        console.log "support_list"
        window.supportList = new SupporPivotTable({el: $("#support-pivottable-content"),model: window.pageModel});
)
