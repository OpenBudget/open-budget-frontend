define ['backbone'], (Backbone) ->
  class SelectedEntity extends Backbone.Model
      defaults:
          selected: null
          expandedDetails: {}

  return SelectedEntity
