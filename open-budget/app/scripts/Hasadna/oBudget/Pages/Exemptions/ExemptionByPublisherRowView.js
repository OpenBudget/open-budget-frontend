import Backbone from 'backbone';
import _ from 'underscore';
import ExemptionDetailsRowView from 'Hasadna/oBudget/Pages/Exemptions/ExemptionDetailsRowView';
import tplExemptionByPublisherRow
  from 'Hasadna/oBudget/Pages/Exemptions/exemption-by-publisher-row.hbs';

export default class ExemptionByPublisherRowView extends Backbone.View {

  events() {
    return {
      'click .exemption-expander .glyphicon': 'toggleDetails',
    };
  }

  tagName() {
    return 'tr';
  }

  initialize() {
    this.detailViews = [];
    this.initialized = false;
  }

  toggleDetails(preselectePublicationId) {
    let selectedRow = null;

    if (!this.initialized) {
      _.each(this.model.exemptions, (exemption) => {
        const detailView = new ExemptionDetailsRowView({
          model: exemption,
        });
        this.$el.after(detailView.render().$el);
        this.detailViews.push(detailView);

        if (exemption.publication_id === preselectePublicationId) {
          selectedRow = detailView;
        }
      });

      if (selectedRow) {
        selectedRow.toggleDetails();
        selectedRow.el.scrollIntoView(true);
      }

      this.initialized = true;
    }

    this.model.expanded = !this.model.expanded;
    if (this.model.expanded) {
      this.$el.find('.open').hide();
      this.$el.find('.collapse').show();
      this.showAllDetailViews();
    } else {
      this.$el.find('.open').show();
      this.$el.find('.collapse').hide();
      this.hideAllDetailViews();
    }
  }

  showAllDetailViews() {
    _.each(this.detailViews, (detailView) => {
      detailView.showFullDetailsView();
    });
  }

  hideAllDetailViews() {
    _.each(this.detailViews, (detailView) => {
      detailView.hideFullDetailsView();
    });
  }

  render() {
    this.$el.html(tplExemptionByPublisherRow(this.model));
    this.$el.find('.collapse').hide();

    return this;
  }
}
