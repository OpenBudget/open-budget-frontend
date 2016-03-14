import Backbone from 'backbone';
import template from './template.hbs';

export default class View extends Backbone.View {

  tagName() {
    return 'article';
  }

  id() {
    return 'main-page-article';
  }

  className() {
    return 'single-page-article';
  }

  initialize() {
    this.$el.html(template());
  }
}
