import Backbone from 'backbone';

export default class Procurement extends Backbone.Model {

  initialize(attrs, options) {
    this.baseURL = options.baseURL;
  }

  url() {
    return `${this.baseURL}/api/procurement/${this.id}`;
  }
}
