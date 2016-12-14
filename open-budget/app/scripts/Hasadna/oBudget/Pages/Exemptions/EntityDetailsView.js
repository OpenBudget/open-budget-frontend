import Backbone from 'backbone';
import _ from 'underscore';
import EntityModel from 'Hasadna/oBudget/Pages/Exemptions/DataStruct/Entity';
import ExemptionModel from 'Hasadna/oBudget/Pages/Exemptions/DataStruct/Exemption';
import ExemptionByPublisherRowView
  from 'Hasadna/oBudget/Pages/Exemptions/ExemptionByPublisherRowView';
import tplEntityDetails from 'Hasadna/oBudget/Pages/Exemptions/entity-details.hbs';
import tplOrphanExemptionDetails
  from 'Hasadna/oBudget/Pages/Exemptions/orphan-exemption-details.hbs';
import EntityVizView from 'Hasadna/oBudget/Pages/Exemptions/EntityViz/View';
import normalize from './DataStruct/OfficeNormalizer';


export default class EntityDetailsView extends Backbone.View {
  className() {
    return 'entity-details center-block col-sm-9';
  }

  initialize(options) {
    this.baseURL = options.baseURL;
    this.listenTo(this.model, 'change:publicationId', this.publicationSelected);

    if (this.model.get('publicationId')) {
      this.publicationSelected();
    } else if (this.model.get('entityId')) {
      this.entitySelected();
    }

    this.currentReqeust = null;
  }

  publicationSelected() {
    const eid = this.model.get('entityId');

    if (eid !== '') {
      this.entity = new EntityModel({}, {
        baseURL: this.baseURL,
        entityId: eid,
      });

      // if (this.currentReqeust) {
      //   //this.currentReqeust.abort();
      // }

      this.currentReqeust = this.entity.doFetch();
      this.$el.toggleClass('loading', true);

      this.entity.on('ready', () => this.render());
    } else {
      // orphan exemption
      this.exemption = new ExemptionModel({}, {
        baseURL: this.baseURL,
        publicationId: this.model.get('publicationId'),
      });

      // if (this.currentReqeust) {
      //   //this.currentReqeust.abort();
      // }
      this.currentReqeust = this.exemption.doFetch();

      this.exemption.on('ready', () => this.renderOrphan());
    }
  }

  entitySelected() {
    this.entity = new EntityModel({}, {
      baseURL: this.baseURL,
      entityId: this.model.get('entityId'),
    });
    // if (this.currentReqeust) {
    //   //this.currentReqeust.abort();
    // }

    this.currentReqeust = this.entity.doFetch();

    this.entity.on('ready', () => this.render());
  }

  render() {
    this.$el.toggleClass('loading', false);

    let procurementsSum = 0;
    const data = this.entity.toJSON();
    data.hasProcurements = data.procurements.length > 0;
    data.procurements = _.groupBy(data.procurements, item => normalize(item.report_publisher));
    const procurementCount = _.keys(data.procurements).length;
    for (const sectorName in data.procurements) {
      if (data.procurements.hasOwnProperty(sectorName)) {
        const sector = data.procurements[sectorName];
        sector.executed = Math.round(sector.reduce((x, y) => x + y.executed, 0));
        const years = sector.map(x => (x.order_date != null ?
                                       Number(x.order_date.split('/').pop()) : 2015))
                            .map(Number);
        const endYear = Math.max.apply(Math, years);
        const startYear = Math.min.apply(Math, years);
        sector.years = endYear === startYear ? endYear : `${startYear}-${endYear}`;
        const groupedSector = _.groupBy(sector, item => item.order_id);
        for (const groupName of Object.keys(groupedSector)) {
          const group = groupedSector[groupName];
          const groupYears = group.map(x => (x.order_date != null ?
                                       Number(x.order_date.split('/').pop()) : 2015))
                            .map(Number);
          const groupEnd = Math.max.apply(Math, groupYears);
          const groupStart = Math.min.apply(Math, groupYears);
          group.years = groupEnd === groupStart ? groupEnd : `${groupStart}-${groupEnd}`;

          group.approved = group[0].volume;
          group.executed = group[0].executed;

          group.order_date = group[0].order_date;
          group.order_id = group[0].order_id;
          group.manof_ref = group[0].manof_ref;
          group.budget_code = group[0].budget_code;
          group.purpose = group[0].purpose;
          group.budget_title = group[0].budget_title;
        }
        sector.groupedSector = groupedSector;
        procurementsSum += sector.executed;
        data.procurements[sectorName] = sector;
      }
    }

    data.supports_procurements_sum = procurementsSum + data.supportsBySubject.sum;
    data.supports_procurements_count = procurementCount + data.supportsBySubject.count;
    // remove from supports the sum and count
    delete data.supportsBySubject.sum;
    delete data.supportsBySubject.count;
    this.$el.html(tplEntityDetails(data));
    // for each exemption by publisher, build a view and render it, and append it
    // to the table body
    const exemptionByPublisherBody = this.$el.find('.exemption-table tbody');
    const exemptionsByPublisher = this.entity.exemptionsByMinistry;
    const iterable = _.values(exemptionsByPublisher);
    for (let i = 0, exemptionByPublisher; i < iterable.length; i++) {
      exemptionByPublisher = iterable[i];

      const rowView = new ExemptionByPublisherRowView({
        model: exemptionByPublisher,
      });

      exemptionByPublisherBody.append(rowView.render().el);

      if (_.where(exemptionByPublisher.exemptions, {
        publication_id: this.model.get('publicationId') * 1,
      }).length > 0) {
        rowView.toggleDetails(this.model.get('publicationId') * 1);
      }
    }
    this.$el.find('h3.entity-title span.total').text(Object.keys(exemptionsByPublisher).length);
    //  this.$el.find('.entity-title-top').click(() => {
    //  console.log('hop');
    //  });

    this.$el.find('.scroll-viewport').scroll(() => {
      if (this.$el.find('.scroll-viewport').scrollTop() > 170) {
        this.$el.find('.entity-top-section').addClass('shrink');
      } else {
        this.$el.find('.entity-top-section').removeClass('shrink');
      }
    });

    const entityViz = new EntityVizView({
      entity: this.entity,
    });
    entityViz.toString();
    return this;
  }

  renderOrphan() {
    const data = this.exemption.toJSON();

    data.exemptions_sum = data.volume;
    data.name = data.supplier;
    data.kind = data.entity_kind;

    this.$el.html(tplOrphanExemptionDetails(data));
  }

}
