define ['backbone'], (Backbone) ->
  class Router extends Backbone.Router
    routes:
      "spending//2014/main": "exemptions"
      "entity/:entityId/2014/main": "exemptions"
      "entity/:entityId/publication/:publication/2014/main": "exemptions"
