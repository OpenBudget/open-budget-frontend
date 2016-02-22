import Backbone from 'backbone';
import tplLatestSpendingUpdates
  from 'Hasadna/oBudget/Pages/Exemptions/latest-spending-updates.hbs';

export default class ExemptionsView extends Backbone.View {

  className() {
    return 'latest-updates col-sm-3';
  }

  events() {
    return {
      'click .exemption-alert:not(.selected)': 'exemptionAlertClick',
      'change select#spendings-day-limit': 'spendingsDayLimitChange',
    };
  }

  initialize() {
    this.listenTo(this.model, 'change:publicationId', this.exemptionSelected);
    this.listenTo(this.model, 'change:exemptionsToDisplay', this.render);

    return this.listenTo(this.model, 'change:loadingExemptions', this.toggleLoading);
  }

  toggleLoading() {
    return this.$el.toggleClass('loading', this.model.get('loadingExemptions'));
  }

  isMobileView() {
    return window.matchMedia('all and (max-width:768px)').matches;
  }

  exemptionAlertClick(e) {
    this.trigger('exemption-selected', this.$el.find(e.currentTarget)
      .data('entity-id'), this.$el.find(e.currentTarget)
      .data('publication-id'));
  }

  spendingsDayLimitChange(e) {
    return this.trigger('days-range-change', this.$el.find(e.target).val());
  }

  exemptionSelected() {
    this.$el.find('.exemption-alert.selected').removeClass('selected');

    this.$el
      .find(`.exemption-alert[data-publication-id=${this.model.get('publicationId')}]`)
      .addClass('selected');
  }

  render() {
    const data = {
      ui: this.model.toJSON(),
    };

    this.$el.html(tplLatestSpendingUpdates(data));

    const len = this.$el
      .find(`.exemption-alert[data-publication-id=${this.model.get('publicationId')}]`).length;

    if (this.model.get('publicationId') && len) {
      this.exemptionSelected();
    }

    if (!this.isMobileView()) {
      this.$el.find('.exemption-alert:first').not('.empty').trigger('click');
    }
  }
}
