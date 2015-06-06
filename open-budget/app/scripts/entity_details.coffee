class EntityDetailsView extends Backbone.View

        initialize: ->
#            @model.on 'ready-entity', => @render()
            @model.entity.on 'ready', => @render()
            console.log 'EntityDetailsView init'

        render: ->
            @$el.css('display','inherit')
            data = @model.entity.toJSON()
            console.log 'render', data
            @$el.html window.JST.entity_details( data )

$( ->
        console.log "entity-details"
        if window.pageModel.get("entityId")?
            window.entityDetails = new EntityDetailsView({el: $("#entity-details"),model: window.pageModel});
)
