define [
    "backbone",
    "modernizr",
    "scripts/hello",
    "scripts/searchbar",
    "scripts/training",
    "scripts/subscribe",
    "scripts/team",
    "scripts/main_page_vis",
    "scripts/budget_view",
    "scripts/breadcrumb_header",
    "scripts/analysis_header",
    "scripts/single_changegroup",
    "Hasadna/oBudget/Pages/Exemptions/Main",
    "Hasadna/oBudget/Router",
    "scripts/models",
    "bootstrap-tour"
    ], (Backbone, a, b, c, d, e, f, g, h, i, j, k, ExemptionsPage, Router, models) ->
      require('styles/main.less');

      router = new Router()
      baseURL = models.pageModel.get 'baseURL'

      router.on "route:exemptions", () ->
        new ExemptionsPage().start(baseURL: baseURL)

      router.on "route:entity", (entityId, publicationId) ->
        new ExemptionsPage().start(baseURL: baseURL, entityId: entityId, publicationId: publicationId)

      document.body.style.display = 'none'
      document.body.getBoundingClientRect()
      document.body.style.display = 'block'
      document.body.getBoundingClientRect()
      
      Backbone.history.start pushState: false
