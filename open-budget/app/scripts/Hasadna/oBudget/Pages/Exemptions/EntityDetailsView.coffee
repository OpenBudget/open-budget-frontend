define [
  "backbone",
  "Hasadna/oBudget/Pages/Exemptions/DataStruct/Entity",
  "Hasadna/oBudget/Pages/Exemptions/DataStruct/Exemption",
  "Hasadna/oBudget/Pages/Exemptions/ExemptionByPublisherRowView",
  'Hasadna/oBudget/Pages/Exemptions/dataHelpers',
  "hbs!Hasadna/oBudget/Pages/Exemptions/entity-details",
  "hbs!Hasadna/oBudget/Pages/Exemptions/orphan-exemption-details"
], (Backbone, EntityModel, ExemptionModel, ExemptionByPublisherRowView, dataHelpers, tpl_entity_details, tpl_orphan_exemption_details) ->

  class EntityDetailsView extends Backbone.View

    className: 'entity-details center-block col-sm-9'

    events:
      'mousedown .export-supports': 'prepareExportSupports'
      'mousedown .export-exemptions': 'prepareExportExemptions'

    initialize: (options) ->
      @baseURL = options.baseURL

      @listenTo @model, 'change:publicationId', @publicationSelected

      if @model.get 'publicationId'
        @publicationSelected()

      else if @model.get 'entityId'
        @entitySelected()

      @currentReqeust = null

    prepareExportExemptions: () ->
      if @$el.find('.export-exemptions').attr('href')
        return

      @$el.find('.export-exemptions').attr('href', dataHelpers.getExemptionsExportUrl(@entity.exemptions))

    prepareExportSupports: () ->
      if @$el.find('.export-supports').attr('href')
        return

      @$el.find('.export-supports').attr('href', dataHelpers.getSupportsExportUrl(@entity.supports))

    publicationSelected: ->
      eid = @model.get 'entityId'
      if eid != ""
        @entity = new EntityModel {}, baseURL: @baseURL, entityId: eid
        if (@currentReqeust)
          @currentReqeust.abort()

        @currentReqeust = @entity.doFetch()
        @$el.toggleClass('loading', true)
        @entity.on 'ready', => @render()
      else
        # orphan exemption
        @exemption = new ExemptionModel {}, baseURL: @baseURL, publicationId: @model.get('publicationId')

        if (@currentReqeust)
          @currentReqeust.abort()

        @currentReqeust = @exemption.doFetch()
        @exemption.on 'ready', => @renderOrphan()

    entitySelected: ->
      @entity = new EntityModel {}, baseURL: @baseURL, entityId: @model.get('entityId')

      if (@currentReqeust)
        @currentReqeust.abort()

      @currentReqeust = @entity.doFetch()
      @entity.on 'ready', => @render()

    render: ->
      @$el.toggleClass('loading', false)
      data = @entity.toJSON()
      @$el.html tpl_entity_details( data )

      # for each exemption by publisher, build a view and render it, and append it
      # to the table body
      exemptionByPublisherBody = @$el.find('.exemption-table tbody')
      exemptionsByPublisher = @entity.exemptionsByMinistry
      for exemptionByPublisher in _.values(exemptionsByPublisher)
        rowView = new ExemptionByPublisherRowView(model: exemptionByPublisher)
        exemptionByPublisherBody.append(rowView.render().el)

        if _.where(exemptionByPublisher.exemptions, {publication_id: @model.get('publicationId') * 1}).length > 0
          rowView.toggleDetails(@model.get('publicationId') * 1)

      @$el.find('h3.entity-title span.total').text(Object.keys(exemptionsByPublisher).length)
      @

    renderOrphan: ->
      data = @exemption.toJSON()

      data['exemptions_sum'] = data['volume']
      data['name'] = data['supplier']
      data['kind'] = data['entity_kind']

      @$el.html tpl_orphan_exemption_details( data )

  EntityDetailsView
