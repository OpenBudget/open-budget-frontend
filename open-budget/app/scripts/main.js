import Backbone from 'backbone';
import $ from 'jquery';
import 'modernizr';
import 'scripts/shame';
import 'scripts/shameCoffee';
import SearchBar from 'scripts/searchbar';
import TrainingView from 'scripts/training';
import 'scripts/subscribe';
import populateTeamModal from 'scripts/team';
import ExemptionsPage from 'Hasadna/oBudget/Pages/Exemptions/Main';
import BudgetItemPage from 'Hasadna/oBudget/Pages/BudgetItem/Main';
import TransferPage from 'Hasadna/oBudget/Pages/Transfer/Main';
import MainPage from 'Hasadna/oBudget/Pages/Main/Main';
import Router from 'Hasadna/oBudget/Router';
import URLSchemeHandler from 'scripts/URLSchemeHandler';
import appConfig from 'scripts/appConfig';

require('styles/main.less');

let currentPage;

$(() => {
  populateTeamModal();
});

const DEFAULT_HOME = 'main';
const DEFAULT_YEAR = 2015;

const URLSchemeHandlerInstance = new URLSchemeHandler(DEFAULT_YEAR, DEFAULT_HOME);

window.addEventListener(
  'hashchange',
  URLSchemeHandlerInstance.handleSchemeChange.bind(URLSchemeHandlerInstance)
);

document.querySelector('a#spending-link')
  .setAttribute('href', URLSchemeHandlerInstance.linkToSpending());

// Expose as global to use in html templates ):
window.URLSchemeHandlerInstance = URLSchemeHandlerInstance;

const searchData = {
  year: DEFAULT_YEAR,
  budgetCode: null,
};

const search = new SearchBar({
  el: '#search-widget',
  searchData,
  URLSchemeHandlerInstance,
});
// This is here just to stop the eslint warnings
search.toString();

const router = new Router();

// We pass this promise resolve function
// to pages that needs tour to let then tell us that they are ready
let pageWithTourReadyResolve;
const pageWithTourReady = new Promise((resolve) => {
  pageWithTourReadyResolve = resolve;
});

router.on('route', (routeName) => {
  // The footer is hidden and then showed on most of the pages
  // to avoid footer flash and hide
  if (routeName !== 'exemptions') {
    $('.footer.wait-for-it').removeClass('wait-for-it');
  }
});

router.on('route:main-page', () => {
  // ignore no page reload routes for now
  if (currentPage) {
    return;
  }

  currentPage = new MainPage(URLSchemeHandlerInstance, pageWithTourReadyResolve);

  currentPage.getView().$el.addClass('active');
  $('body > div > .footer').before(currentPage.getView().el);
  currentPage.afterAppend();
});

router.on('route:transfer-page', (code, year) => {
  // ignore no page reload routes for now
  if (currentPage) {
    return;
  }

  currentPage = new TransferPage(code, year, pageWithTourReadyResolve);

  $('#change-group-article').addClass('active').append(currentPage.getView().el);
  currentPage.afterAppend();
});

router.on('route:exemptions', () => {
  // ignore no page reload routes for now
  if (currentPage) {
    return;
  }

  document.body.classList.add('kind-spending');
  currentPage = new ExemptionsPage();
  currentPage.start({ baseURL: appConfig.baseURL });
  $('#spendings-page-article').addClass('active');
});

router.on('route:entity', (entityId, publicationId) => {
  // ignore no page reload routes for now
  if (currentPage) {
    return;
  }

  currentPage = new ExemptionsPage();
  currentPage.start({ baseURL: appConfig.baseURL, entityId, publicationId });
  $('#entity-article').addClass('active');
});

router.on('route:budget-page', (budgetCode, budgetYear) => {
  // ignore no page reload routes for now
  if (currentPage) {
    return;
  }

  searchData.budgetCode = budgetCode;

  currentPage = new BudgetItemPage(
    `00${budgetCode || ''}`,
    budgetYear || DEFAULT_YEAR,
    URLSchemeHandlerInstance,
    pageWithTourReadyResolve
  );

  $('#budget-item-article').addClass('active').append(currentPage.getView().el);

  currentPage.afterAppend();
});

Backbone.history.start({ pushState: false });

function shouldNotTour() {
  // tour should start only on the main page
  if (!(currentPage instanceof MainPage) && !sessionStorage.getItem('touring')) {
    return true;
  }

  // when focused on a bubble when not while tour, don't start it
  if (
      currentPage instanceof MainPage &&
      location.hash.indexOf('?') > -1 &&
      !sessionStorage.getItem('touring')
    ) {
    return true;
  }

  return false;
}

pageWithTourReady.then(() => {
  if (shouldNotTour()) {
    return;
  }

  const training = new TrainingView({
    el: '#intro-link',
    flow: URLSchemeHandlerInstance.linkParameters.flow,
  });

  training.toString();
});
