import Backbone from 'backbone';
import SpendingLine from 'Hasadna/oBudget/Pages/Exemptions/DataStruct/SpendingLine';

export default class Exemption extends Backbone.Model {

  initialize(attrs, options) {
    this.baseURL = options.baseURL;
    this.publicationId = options.publicationId;
  }

  doFetch() {
    return this.fetch({ success: this.handleFetchResult });
  }

  url() {
    return `${this.baseURL}/api/exemption/publication/${this.publicationId}`;
  }

  handleFetchResult() {
    this.trigger('ready');
  }
}

Exemption.prototype.parse = SpendingLine.prototype.parse;
