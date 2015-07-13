class EntityDetailsView extends Backbone.View
        events:
          'click .exemption-expander': 'toggleExemptionDetails'

        initialize: ->
            @model.selectedEntity.on 'change:selected', =>
                eid = @model.selectedEntity.get('selected')
                @entity = new models.Entity(pageModel: window.pageModel, entityId: eid)
                @entity.doFetch()
                @entity.on 'ready', => @render()

        render: ->
            @$el.css('display','inherit')
            data = @entity.toJSON()
            @$el.html window.JST.entity_details( data )
            
            # for each exemption by publisher, build a view and render it, and append it
            # to the table body
            exemptionByPublisherBody = @$el.find('#exemption-table tbody')
            exemptionsByPublisher = @entity.exemptionsByPublisher()
            for exemptionByPublisher in _.values(exemptionsByPublisher)
                rowView = new ExemptionByPublisherRowView(model: exemptionByPublisher)
                exemptionByPublisherBody.append(rowView.render().el)
            @$el.find('h3#entity-title span#total').text(Object.keys(exemptionsByPublisher).length);
            @

class ExemptionByPublisherRowView extends Backbone.View
    events:
        'click .exemption-expander .glyphicon': 'toggleDetails'
    tagName: 'tr'
    initialize: ->
        @detailViews = []

    toggleDetails: ->
        @model.expanded = !@model.expanded

        # make sure to clear all views in case we for some reason double add them below
        @clearDetailViews()

        if(@model.expanded)
            # insert details view row for each exemption after the current publisher row
            # this essentially adds rows to the main table
            _.each @model.exemptions, (exemption) =>
                detailView = new ExemptionDetailsRowView(model: exemption)
                @$el.after(detailView.render().$el)
                @detailViews.push(detailView)
            @$el.find('.open').hide()
            @$el.find('.collapse').show()
        else
            @$el.find('.open').show()
            @$el.find('.collapse').hide()

    clearDetailViews: ->
        _.each @detailViews, (detailView) =>
            detailView.remove()

        #TODO: Now there's a bug that when we close the upper row, it closes ALL the details exemptions. Contact Johnny or Shay
        $(@$el[0]).parent().find(".exemption-full-details").remove()

        # clear array
        @detailViews = []

    render: ->
        @$el.html window.JST.exemption_by_publisher_row(@model)
        @$el.find('.collapse').hide()
        @

class ExemptionDetailsRowView extends Backbone.View
    events:
        'click .exemption-full-details-expander .open': 'toggleDetails'
        'click .exemption-full-details-expander .collapse': 'toggleDetails'
    tagName: 'tr'
    className: 'detailsRow'
    render: ->
        @$el.html window.JST.exemption_details_row(@model)
        @$el.find('.open').show()
        @$el.find('.collapse').hide()
        @
    remove: ->
        @$el.detach()
        @undelegateEvents()

    toggleDetails: ->
        @model.expanded = !@model.expanded

        # make sure to clear all views in case we for some reason double add them below
        @clearFullDetailsView()

        if(@model.expanded)
            # insert details view row for each exemption after the current publisher row
            # this essentially adds rows to the main table
#            _.each @model.exemptions, (exemption) =>
#                detailView = new ExemptionDetailsRowView(model: exemption)
#                @$el.after(detailView.render().$el)
#                @detailViews.push(detailView)

            detailView = new ExemptionFullDetailsView(model: @model)
            @$el.after(detailView.render().$el)
            @detailView = detailView
            @fullDetailsViews
            @$el.find('.open').hide()
            @$el.find('.collapse').show()
        else
            @$el.find('.collapse').hide()
            @$el.find('.open').show()

    clearFullDetailsView: ->
        if @detailView?
            @detailView.remove()


class ExemptionFullDetailsView extends Backbone.View
    tagName: 'tr'
    className: 'fullDetailsRow'
    render: ->
        @$el.html window.JST.exemption_full_details(@model)
        @
    remove: ->
        @$el.detach()
        @undelegateEvents()

$(->
    console.log "entity-details"
    if window.pageModel.get("entityId")?
        window.entityDetails = new EntityDetailsView({el: $("#entity-details"), model: window.pageModel});
)

window.EntityDetailsView = EntityDetailsView
