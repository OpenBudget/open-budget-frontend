class SpendingPivotTable extends Backbone.View

    initialize: ->
            @pageModel = window.pageModel
            @pageModel.on 'ready-spending', => @render()
            @renderers = $.extend($.pivotUtilities.renderers,
                    $.pivotUtilities.d3_renderers);

    render: ->
        if @pageModel.spending?
            console.log 'pass'
            # locale = "he"
            # jsons = _.map(@pageModel.spending.models, (x) -> x.toLocaleJSON(locale))
            # @$el.pivotUI(jsons, {
            #   rows: [pageModel.supportFieldNormalizer.normalize("subject", locale),
            #          pageModel.supportFieldNormalizer.normalize("title", locale),
            #          pageModel.supportFieldNormalizer.normalize("recipient", locale)],
            #   cols: [pageModel.supportFieldNormalizer.normalize("year", locale)],
            #   aggregatorName: "Sum",
            #   renderers: @renderes,
            #   rendererName: "Heatmap",
            #   vals: [pageModel.supportFieldNormalizer.normalize("amount_supported", locale)]
            # });

$( ->
        console.log "support_list"
        window.supportList = new SpendingPivotTable({el: $("#spending-pivottable-content"),model: window.pageModel});
)
