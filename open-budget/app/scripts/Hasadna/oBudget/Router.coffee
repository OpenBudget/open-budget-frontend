define ['backbone'], (Backbone) ->
  class Router extends Backbone.Router
    routes:
      "spending(*yeaorwhatever)": "exemptions"
      "entity/:entityId": "entity"
      "entity/:entityId/publication/:publication(/yeaorwhatever)": "entity"
      "entity/:entityId(/yeaorwhatever)": "entity"
