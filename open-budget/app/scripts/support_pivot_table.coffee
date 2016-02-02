define(['backbone', 'underscore', 'pivot'], (Backbone, _, pivot) ->
    class SupporPivotTable extends Backbone.View

        initialize: ->
                @model.on 'ready-supports', => @render()
                @renderers = $.extend($.pivotUtilities.renderers,
                        $.pivotUtilities.d3_renderers);

        render: ->
            if @model.supports?
                locale = "he"
                jsons = _.map(@model.supports.models, (x) -> x.toLocaleJSON(locale))
                @$el.pivotUI(jsons, {
                  rows: [@model.supportFieldNormalizer.normalize("subject", locale),
                         @model.supportFieldNormalizer.normalize("title", locale),
                         @model.supportFieldNormalizer.normalize("recipient", locale)],
                  cols: [@model.supportFieldNormalizer.normalize("year", locale)],
                  aggregatorName: "Sum",
                  renderers: @renderes,
                  rendererName: "Heatmap",
                  vals: [@model.supportFieldNormalizer.normalize("amount_supported", locale)]
                });

    return SupporPivotTable
)
