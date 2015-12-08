define ['backbone'], (Backbone) ->
  class SelectedEntity extends Backbone.Model
      defaults:
          entity_id: null
          publication_id: null
          expandedDetails: {}

  return SelectedEntity
