class EntityDetailsView extends Backbone.View
        events:
          'click .exemption-expander': 'toggleExemptionDetails'

        initialize:  ->
            @model.selectedEntity.on 'change:selected', =>
                eid = @model.selectedEntity.get('selected')
                @entity = new models.Entity(pageModel: window.pageModel, entityId: eid)
                @entity.doFetch()
                @entity.on 'ready', => @render()
            console.log 'EntityDetailsView init'

        render: ->
            @$el.css('display','inherit')
            data = @entity.toJSON()
            console.log 'render', data
            @$el.html window.JST.entity_details( data )

            # for each exemption by publisher, build a view and render it, and append it
            # to the table body
            exemptionByPublisherBody = @$el.find('.exemption-table tbody')
            exemptionsByPublisher = @entity.get 'exemptions_by_publisher'
            for exemptionByPublisher in _.values(exemptionsByPublisher)
              rowView = new ExemptionByPublisherRowView(model: exemptionByPublisher)
              exemptionByPublisherBody.append(rowView.render().el)
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
      @$el.find('.collapse').hide()
      @$el.find('.open').show()

  clearDetailViews: ->
    _.each @detailViews, (detailView) =>
      detailView.remove()

    # clear array
    @detailViews = []

  render: ->
    @$el.html window.JST.exemption_by_publisher_row(@model)
    @$el.find('.collapse').hide()
    @

class ExemptionDetailsRowView extends Backbone.View
  tagName: 'tr'
  className: 'detailsRow'
  render: ->
    @$el.html window.JST.exemption_details_row(@model)
    @
  remove: ->
    @$el.detach()
    @undelegateEvents()

$( ->
        console.log "entity-details"
        if window.pageModel.get("entityId")?
            window.entityDetails = new EntityDetailsView({el: $("#standalone-entity-details"),model: window.pageModel})
            window.pageModel.selectedEntity.set 'selected',window.pageModel.get("entityId"))

window.EntityDetailsView = EntityDetailsView
