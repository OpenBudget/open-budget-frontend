import Backbone from 'backbone';

export default class Router extends Backbone.Router {
  routes() {
    return {
      'spending(*yeaorwhatever)': 'exemptions',
      'entity/:entityId': 'entity',
      'entity/:entityId/publication/:publication(*yeaorwhatever)': 'entity',
      'entity/:entityId(*yeaorwhatever)': 'entity',
    };
  }
}
