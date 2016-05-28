import _ from 'underscore';
import Backbone from 'backbone';
import SpendingLine from 'Hasadna/oBudget/Pages/Exemptions/DataStruct/SpendingLine';
import Procurements from 'Hasadna/oBudget/Pages/Exemptions/DataStruct/Procurements';
import dataHelpers from 'Hasadna/oBudget/Pages/Exemptions/dataHelpers';

export default class Entity extends Backbone.Model {

  defaults() {
    return {
      kind: null,
      name: null,
      supports: [],
      exemptions: [],
      procurements: [],
      id: null,
      exemptions_by_publisher: {},
      exemptions_sum: null,
    };
  }

  initialize(attrs, options) {
    this.baseURL = options.baseURL;
    this.entityId = options.entityId;
  }

  doFetch() {
    this.procurements = new Procurements(null, {
      baseURL: this.baseURL,
      entity_id: this.entityId
    });

    return this.procurements.fetch()
      .then(() => {
        this.set('procurements', this.procurements.toJSON());
      })
      .then(() => {
        return this.fetch({ success: this.handleFetchResult.bind(this) });
      });
  }

  url() {
    return `${this.baseURL}/api/entity/${this.entityId}`;
  }

  handleFetchResult(collection, response) {
    this.supports = response.supports;
    this.exemptions = response.exemptions ?
      response.exemptions.map(SpendingLine.prototype.parse) :
      [];

    this.set('exemptions_sum', this.getExemptionsTotalVolume());

    this.ministriesAliasesMap = dataHelpers.generateAliasesMap(this.getRawMinistriesList());

    this.exemptionsByPublisherList = this.exemptionsByPublisher();
    this.exemptionsByMinistry = this.getExemptionsByMinistry();

    this.trigger('ready');
  }

  getRawMinistriesList() {
    return _.unique(this.exemptions.map((exemption) => exemption.publisher));
  }

  getExemptionsTotalVolume() {
    let exemptionsSum = 0;

    if (this.exemptions) {
      const iterable = this.exemptions;

      for (let i = 0, exemption; i < iterable.length; i++) {
        exemption = iterable[i];
        exemptionsSum += exemption.volume;
      }
    }

    return exemptionsSum;
  }

  getExemptionsByMinistry() {
    const exemptionsByMinistry = {};
    const iterable = this.exemptions;

    for (let i = 0, exemption; i < iterable.length; i++) {
      exemption = iterable[i];
      const ministry = this.ministriesAliasesMap[exemption.publisher];

      if (!exemptionsByMinistry[ministry]) {
        exemptionsByMinistry[ministry] = { publisher: ministry, exemptions: [], total_volume: 0 };
      }

      exemption.ministry = ministry;

      exemptionsByMinistry[ministry].exemptions.splice(0, 0, exemption);
      exemptionsByMinistry[ministry].total_volume += exemption.volume;
      exemptionsByMinistry[ministry].start_date = this.minDate(
        exemptionsByMinistry[ministry].start_date, exemption.start_date
      );
      exemptionsByMinistry[ministry].end_date = this.maxDate(
        exemptionsByMinistry[ministry].end_date, exemption.end_date
      );
    }

    return exemptionsByMinistry;
  }

  exemptionsByPublisher() {
    const exemptionsByPublisher = {};

    if (this.exemptions) {
      const iterable = this.exemptions;

      for (let i = 0, exemption; i < iterable.length; i++) {
        exemption = iterable[i];

        if (!(exemptionsByPublisher[exemption.publisher])) {
          exemptionsByPublisher[exemption.publisher] = {
            publisher: exemption.publisher, exemptions: [], total_volume: 0,
          };
        }

        exemptionsByPublisher[exemption.publisher].exemptions.splice(0, 0, exemption);
        exemptionsByPublisher[exemption.publisher].total_volume += exemption.volume;
        exemptionsByPublisher[exemption.publisher].start_date = this.minDate(
          exemptionsByPublisher[exemption.publisher].start_date, exemption.start_date
        );

        exemptionsByPublisher[exemption.publisher].end_date = this.maxDate(
          exemptionsByPublisher[exemption.publisher].end_date, exemption.end_date
        );
      }
    }

    for (const publisher in exemptionsByPublisher) {
      if (exemptionsByPublisher.hasOwnProperty(publisher)) {
        exemptionsByPublisher[publisher].start_date = exemptionsByPublisher[publisher].start_date;
        exemptionsByPublisher[publisher].end_date = exemptionsByPublisher[publisher].end_date;
      }
    }

    return exemptionsByPublisher;
  }

  minDate(a, b) {
    if (!(typeof a !== 'undefined' && a !== null)) {
      return b;
    }

    if (!(typeof b !== 'undefined' && b !== null)) {
      return a;
    }

    if (a.getTime() < b.getTime()) {
      return a;
    }

    return b;
  }

  maxDate(a, b) {
    if (!(typeof a !== 'undefined' && a !== null)) {
      return b;
    }

    if (!(typeof b !== 'undefined' && b !== null)) {
      return a;
    }

    if (a.getTime() < b.getTime()) {
      return b;
    }

    return a;
  }
}
