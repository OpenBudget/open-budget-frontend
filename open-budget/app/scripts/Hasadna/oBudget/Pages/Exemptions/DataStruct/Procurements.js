import Backbone from 'backbone';


class Procurement extends Backbone.Model {

}

class Procurements extends Backbone.Collection {
  initialize (attrs, options) {
    this.baseURL = options.baseURL;
    this.entity_id = options.entity_id;
  }

  url () {
    return `${this.baseURL}/api/procurement/${this.entity_id}`;
  }

  model (attrs, options) {
    return new Procurement(attrs, options);
  }
}

export {
  Procurements,
  Procurement
}
