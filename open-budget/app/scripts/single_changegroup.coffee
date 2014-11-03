class SingleChangeGroupView extends Backbone.View

        initialize: ->
            @model.on 'ready-changegroup', => @render()
            console.log 'SingleChangeGroupView init'

        render: ->
            console.log 'render', @model.changeGroup.toJSON()
            @$el.css('display','inherit')
            data = @model.changeGroup.toJSON()
            data.explanation = @model.changeGroupExplanation.get('explanation')
            @$el.html window.JST.single_changegroup( data )

$( ->
        console.log "single-changegroup"
        if window.pageModel.get("changeGroupId")?
            window.singleChangegroup = new SingleChangeGroupView({el: $("#single-changegroup"),model: window.pageModel});
)
