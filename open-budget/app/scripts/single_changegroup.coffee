define(['backbone', 'models'], (Backbone, models) ->
    class SingleChangeGroupView extends Backbone.View

            initialize: ->
                @model.on 'ready-changegroup', => @render()

            render: ->
                @$el.css('display','inherit')
                data = @model.changeGroup.toJSON()
                data.explanation = ""
                @$el.html window.JST.single_changegroup( data )
                if @model.changeGroupExplanation.get('explanation')?
                    data.explanation = @model.changeGroupExplanation.get('explanation')
                    @$el.html window.JST.single_changegroup( data )
                @model.changeGroupExplanation.on('change:explanation', =>
                    data.explanation = @model.changeGroupExplanation.get('explanation')
                    @$el.html window.JST.single_changegroup( data )
                )

    if models.pageModel.get("changeGroupId")?
        window.singleChangegroup = new SingleChangeGroupView({el: $("#single-changegroup"),model: models.pageModel});

    SingleChangeGroupView
)
