require [
    "backbone",
    "modernizr",
    "hello",
    "searchbar",
    "training",
    "subscribe",
    "team",
    "main_page_vis",
    "budget_view",
    "breadcrumb_header",
    "analysis_header",
    "single_changegroup",
    "Hasadna/oBudget/Pages/Exemptions/Main",
    "Hasadna/oBudget/Router",
    "models",
    "bootstrap-tour"
    ], (Backbone, a, b, c, d, e, f, g, h, i, j, k, ExemptionsPage, Router, models) ->
      router = new Router()
      baseURL = models.pageModel.get 'baseURL'

      router.on "route:exemptions", (entityId, publicationId) ->
        new ExemptionsPage().start(baseURL: baseURL, entityId: entityId, publicationId: publicationId)

      Backbone.history.start pushState: false
