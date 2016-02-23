import Backbone from 'backbone';
import _ from 'underscore';
import EntityModel from 'Hasadna/oBudget/Pages/Exemptions/DataStruct/Entity';
import ExemptionModel from 'Hasadna/oBudget/Pages/Exemptions/DataStruct/Exemption';
import ExemptionByPublisherRowView
  from 'Hasadna/oBudget/Pages/Exemptions/ExemptionByPublisherRowView';
import tplEntityDetails from 'Hasadna/oBudget/Pages/Exemptions/entity-details.hbs';
import tplOrphanExemptionDetails
  from 'Hasadna/oBudget/Pages/Exemptions/orphan-exemption-details.hbs';

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

      if (this.currentReqeust) {
        this.currentReqeust.abort();
      }

      this.currentReqeust = this.entity.doFetch();
      this.$el.toggleClass('loading', true);

      this.entity.on('ready', () => this.render());
    } else {
      // orphan exemption
      this.exemption = new ExemptionModel({}, {
        baseURL: this.baseURL,
        publicationId: this.model.get('publicationId'),
      });

      if (this.currentReqeust) {
        this.currentReqeust.abort();
      }
      this.currentReqeust = this.exemption.doFetch();

      this.exemption.on('ready', () => this.renderOrphan());
    }
  }

  entitySelected() {
    this.entity = new EntityModel({}, {
      baseURL: this.baseURL,
      entityId: this.model.get('entityId'),
    });

    if (this.currentReqeust) {
      this.currentReqeust.abort();
    }

    this.currentReqeust = this.entity.doFetch();

    this.entity.on('ready', () => this.render());
  }

  render() {
    this.$el.toggleClass('loading', false);
    const data = this.entity.toJSON();
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
