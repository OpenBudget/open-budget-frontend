import Backbone from 'backbone';
import ExemptionFullDetailsView from 'Hasadna/oBudget/Pages/Exemptions/ExemptionFullDetailsView';
import tplExemptionDetailsRow from 'Hasadna/oBudget/Pages/Exemptions/exemption-details-row.hbs';

export default class ExemptionDetailsRowView extends Backbone.View {

  events() {
    return {
      'click .exemption-full-details-expander .open': 'toggleDetails',
      'click .exemption-full-details-expander .collapse': 'toggleDetails',
    };
  }

  tagName() {
    return 'tr';
  }

  className() {
    return 'detailsRow';
  }

  initialize() {
    this.initialized = false;
  }

  render() {
    this.$el.html(tplExemptionDetailsRow(this.model));
    this.$el.find('.open').show();
    this.$el.find('.collapse').hide();

    return this;
  }

  toggleDetails() {
    if (!this.initialized) {
      this.detailView = new ExemptionFullDetailsView({
        model: this.model,
      });
      this.$el.after(this.detailView.render().$el);
      this.initialized = true;
    }

    this.model.expanded = !this.model.expanded;

    if (this.model.expanded) {
      this.$el.find('.open').hide();
      this.$el.find('.collapse').show();
      this.detailView.toggleShow();
    } else {
      this.$el.find('.collapse').hide();
      this.$el.find('.open').show();
      this.detailView.toggleHide();
    }
  }

  showFullDetailsView() {
    return this.$el.show();
  }

  hideFullDetailsView() {
    this.model.expanded = false;
    this.$el.find('.collapse').hide();
    this.$el.find('.open').show();

    if (this.detailView) {
      this.detailView.toggleHide();
    }

    return this.$el.hide();
  }
}
