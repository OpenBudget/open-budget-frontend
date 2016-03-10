import Backbone from 'backbone';

export default class Router extends Backbone.Router {
  routes() {
    return {
      '': 'main-page',
      '/': 'main-page',
      'main/(*yeaorwhatever)': 'main-page',
      'spending(*yeaorwhatever)': 'exemptions',
      'entity/:entityId': 'entity',
      'entity/:entityId/publication/:publication(*yeaorwhatever)': 'entity',
      'entity/:entityId(*yeaorwhatever)': 'entity',
      'budget/(:code)/:year(/main)': 'budget-page',
      'transfer/:code/:year/(*whatever)': 'transfer-page',
    };
  }
}
