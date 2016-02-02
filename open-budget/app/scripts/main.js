define([
    "backbone",
    "underscore",
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
    'scripts/modelsHelpers/PageModel',
    'scripts/URLSchemeHandler',
    'scripts/appConfig',
    "bootstrap-tour",
    "scripts/main_page_tabs"
    ], function (
      Backbone,
      _,
      modernizr,
      hello,
      SearchBar,
      Training,
      sub,
      team,
      MainPageVis,
      budget_view,
      BreadcrumbHeaderView,
      AnalysisHeaderView,
      SingleChangeGroupView,
      ExemptionsPage, Router, PageModel, URLSchemeHandler, appConfig, tour,
      MainPageTabs
    ) {

      require('styles/main.less');

      var DEFAULT_HOME = "#main//2015/main";

      var URLSchemeHandlerInstance = new URLSchemeHandler();

      window.onhashchange = URLSchemeHandlerInstance.handleSchemeChange
      document.querySelector("a#spending-link").setAttribute('href', URLSchemeHandlerInstance.linkToSpending())

      // Expose as global to use in html templates ):
      window.URLSchemeHandlerInstance = URLSchemeHandlerInstance;

      var pageModel = new PageModel({}, {DEFAULT_HOME: DEFAULT_HOME});
      pageModel.switchView(URLSchemeHandlerInstance.linkParameters);

      var search = new SearchBar({el: "#search-widget", model: pageModel, URLSchemeHandlerInstance: URLSchemeHandlerInstance});

      var mainPageTabs = new MainPageTabs({model: pageModel, URLSchemeHandlerInstance: URLSchemeHandlerInstance});

      var router = new Router();

      router.on("route:exemptions", function () {
        new ExemptionsPage().start({baseURL: appConfig.baseURL});
      });

      router.on("route:entity", function (entityId, publicationId) {
        new ExemptionsPage().start({baseURL: appConfig.baseURL, entityId: entityId, publicationId: publicationId});
      });

      Backbone.history.start({pushState: false});

      var training = new Training({
        el: "#intro-link",
        model: pageModel,
        flow: URLSchemeHandlerInstance.linkParameters.flow
      });

      var mainPageVis = new MainPageVis({el: "#main-page-article", model: pageModel, URLSchemeHandlerInstance: URLSchemeHandlerInstance});

      budget_view.start(pageModel);

      if (pageModel.get('budgetCode')) {
        pageModel.on('ready-breadcrumbs', function () {
          var breadcrumbHeaderView = new BreadcrumbHeaderView({el: "#header-tree", model: pageModel});
          breadcrumbHeaderView.render();

          $("#affix-wrapper").height($("#affix-header").height());
        });

        var analysisHeaderView;
        var callback = _.after(2, function () {
          analysisHeaderView = new AnalysisHeaderView({el: pageModel.article.find(".brief"), model: pageModel});
        });

        pageModel.on('ready-budget-history', callback);
        pageModel.on('ready-breadcrumbs', callback);
      }


      if (pageModel.get("changeGroupId")) {
        var singleChangegroup = new SingleChangeGroupView({el: "#single-changegroup", model: pageModel});
      }

      document.body.style.display = 'none';
      document.body.getBoundingClientRect();
      document.body.style.display = 'block';
      document.body.getBoundingClientRect();
});

