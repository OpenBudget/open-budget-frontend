class EntityDetailsView extends Backbone.View
        initialize:  ->
            @model.selectedEntity.on 'change:selected', =>
                eid = @model.selectedEntity.get('selected')
                @entity = new Entity(pageModel: window.pageModel, entityId: eid)
                @entity.doFetch()
                @entity.on 'ready', => @render()
            console.log 'EntityDetailsView init'

        render: ->
            @$el.css('display','inherit')
            data = @entity.toJSON()
            console.log 'render', data
            @$el.html window.JST.entity_details( data )

$( ->
        console.log "entity-details"
        if window.pageModel.get("entityId")?
            window.entityDetails = new EntityDetailsView({el: $("#entity-details"),model: window.pageModel});
)

window.EntityDetailsView = EntityDetailsView
