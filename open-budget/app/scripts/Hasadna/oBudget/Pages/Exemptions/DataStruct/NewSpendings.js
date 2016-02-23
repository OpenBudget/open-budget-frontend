import $ from 'jquery';
import Backbone from 'backbone';
import _ from 'underscore';
import SpendingLine from 'Hasadna/oBudget/Pages/Exemptions/DataStruct/SpendingLine';

export default class NewSpendings extends Backbone.Collection {

  model(attrs, options) {
    return new SpendingLine(attrs, options);
  }

  initialize(models, options) {
    this.options = options;
  }

  url() {
    return `${this.options.baseURL}/api/exemption/new/30?limit=10000`;
  }

  fetchSplit() {
    const totalLimit = 5000;
    const bulkSize = 1000;

    function mapper(val, index) {
      return $.get(`${this.options.baseURL}/api/exemption/` +
        `new/30?limit=${bulkSize}&first=${bulkSize * index}`);
    }

    const reqs = _.range(totalLimit / bulkSize)
      .map(mapper.bind(this));

    return $.when.apply(null, reqs).then(
      (...args) => _.flatten(args.map((val) => val[0]))
    ).then((exemptions) => this.set(exemptions, { parse: true }));
  }
}
