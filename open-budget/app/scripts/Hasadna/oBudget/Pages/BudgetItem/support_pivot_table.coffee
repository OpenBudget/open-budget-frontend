define(['backbone', 'underscore', 'pivot'], (Backbone, _, pivot) ->
    class SupporPivotTable extends Backbone.View

        initialize: (options)->
          @options = options
          @renderers = $.extend($.pivotUtilities.renderers,
                  $.pivotUtilities.d3_renderers);

        render: ->
            if @options.supports?
                locale = "he"
                jsons = _.map(@options.supports.models, (x) -> x.toLocaleJSON(locale))
                @$el.pivotUI(jsons, {
                  rows: [@options.supportFieldNormalizer.normalize("subject", locale),
                         @options.supportFieldNormalizer.normalize("title", locale),
                         @options.supportFieldNormalizer.normalize("recipient", locale)],
                  cols: [@options.supportFieldNormalizer.normalize("year", locale)],
                  aggregatorName: "Sum",
                  renderers: @renderes,
                  rendererName: "Heatmap",
                  vals: [@options.supportFieldNormalizer.normalize("amount_supported", locale)]
                });

    return SupporPivotTable
)
