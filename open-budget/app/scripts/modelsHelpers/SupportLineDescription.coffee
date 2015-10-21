define ['backbone'], (Backbone) ->
  class SupportLineDescription extends Backbone.Model

    defaults:
        field: null,
        en: null,
        he: null,
        model: null,
        order: null

  return SupportLineDescription
