define([
  'backbone',
  'underscore',
  'templates/single-changegroup.html'
], (Backbone, _, tempalte_single_changegroup) ->
    class SingleChangeGroupView extends Backbone.View

            id: 'single-changegroup'

            className: 'center-block'

            initialize: (options)->
                @options = options

            render: (changeGroupExplanation, changeGroup)->
                @$el.css('display','inherit')
                data = changeGroup.toJSON()
                data.explanation = ""
                data._ = _;
                @$el.html tempalte_single_changegroup( data )
                if changeGroupExplanation.get('explanation')?
                    data.explanation = changeGroupExplanation.get('explanation')
                    @$el.html tempalte_single_changegroup( data )
                changeGroupExplanation.on('change:explanation', =>
                    data.explanation = changeGroupExplanation.get('explanation')
                    @$el.html tempalte_single_changegroup( data )
                )

    SingleChangeGroupView
)
