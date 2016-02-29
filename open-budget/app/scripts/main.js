import Backbone from 'backbone';
import $ from 'jquery';
import 'modernizr';
import 'scripts/hello';
import SearchBar from 'scripts/searchbar';
import Training from 'scripts/training';
import 'scripts/subscribe';
import populateTeamModal from 'scripts/team';
import MainPageVis from 'scripts/main_page_vis';
import { start as budgetViewStart } from 'scripts/budget_view';
import BreadcrumbHeaderView from 'scripts/breadcrumb_header';
import AnalysisHeaderView from 'scripts/analysis_header';
import SingleChangeGroupView from 'scripts/single_changegroup';
import ExemptionsPage from 'Hasadna/oBudget/Pages/Exemptions/Main';
import Router from 'Hasadna/oBudget/Router';
import PageModel from 'scripts/modelsHelpers/PageModel';
import URLSchemeHandler from 'scripts/URLSchemeHandler';
import appConfig from 'scripts/appConfig';
import 'bootstrap-tour';
import MainPageTabs from 'scripts/main_page_tabs';


require('styles/main.less');

$(() => {
  populateTeamModal();
});

const DEFAULT_HOME = '#main//2015/main';

const URLSchemeHandlerInstance = new URLSchemeHandler();

window.onhashchange = URLSchemeHandlerInstance.handleSchemeChange;
document.querySelector('a#spending-link')
  .setAttribute('href', URLSchemeHandlerInstance.linkToSpending());

// Expose as global to use in html templates ):
window.URLSchemeHandlerInstance = URLSchemeHandlerInstance;

const pageModel = new PageModel({}, { DEFAULT_HOME });
pageModel.switchView(URLSchemeHandlerInstance.linkParameters);

const search = new SearchBar({
  el: '#search-widget',
  model: pageModel,
  URLSchemeHandlerInstance,
});

const mainPageTabs = new MainPageTabs({
  model: pageModel,
  URLSchemeHandlerInstance,
});

const router = new Router();

router.on('route:exemptions', () => {
  new ExemptionsPage().start({ baseURL: appConfig.baseURL });
});

router.on('route:entity', (entityId, publicationId) => {
  new ExemptionsPage().start({ baseURL: appConfig.baseURL, entityId, publicationId });
});

Backbone.history.start({ pushState: false });

const training = new Training({
  el: '#intro-link',
  model: pageModel,
  flow: URLSchemeHandlerInstance.linkParameters.flow,
});

const mainPageVis = new MainPageVis({
  el: '#main-page-article',
  model: pageModel,
  URLSchemeHandlerInstance,
});

budgetViewStart(pageModel);

if (pageModel.get('budgetCode')) {
  pageModel.on('ready-breadcrumbs', () => {
    const breadcrumbHeaderView = new BreadcrumbHeaderView({ el: '#header-tree', model: pageModel });
    breadcrumbHeaderView.render();

    $('#affix-wrapper').height($('#affix-header').height());
  });

  const readyBudgetHistory = new Promise((resolve) => {
    pageModel.on('ready-budget-history', resolve);
  });

  const readyBreadcrumbs = new Promise((resolve) => {
    pageModel.on('ready-breadcrumbs', resolve);
  });

  Promise.all([readyBudgetHistory, readyBreadcrumbs]).then(() => {
    const analysisHeaderView = new AnalysisHeaderView({
      el: pageModel.article.find('.brief'), model: pageModel,
    });

    return analysisHeaderView;
  });
}

let singleChangegroup;
if (pageModel.get('changeGroupId')) {
  singleChangegroup = new SingleChangeGroupView({
    el: '#single-changegroup',
    model: pageModel,
  });
}

document.body.style.display = 'none';
document.body.getBoundingClientRect();
document.body.style.display = 'block';
document.body.getBoundingClientRect();

// This is here just to stop the eslint warnings
export {
  singleChangegroup,
  training,
  mainPageVis,
  mainPageTabs,
  search,
};
