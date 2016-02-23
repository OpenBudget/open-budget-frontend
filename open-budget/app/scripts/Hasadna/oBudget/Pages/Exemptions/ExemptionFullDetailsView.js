import Backbone from 'backbone';
import tplExemptionFullDetails from 'Hasadna/oBudget/Pages/Exemptions/exemption-full-details.hbs';

export default class ExemptionFullDetailsView extends Backbone.View {

  tagName() {
    return 'tr';
  }

  className() {
    return 'fullDetailsRow';
  }

  render() {
    this.$el.html(tplExemptionFullDetails(this.model));

    return this;
  }

  toggleShow() {
    this.$el.show('0', () => {
      this.$el.find('div.exemption-full-details-div').slideDown('slow');
    });
  }

  toggleHide() {
    this.$el.hide('0', () => {
      this.$el.find('div.exemption-full-details-div').slideUp('slow');
    });
  }
}
