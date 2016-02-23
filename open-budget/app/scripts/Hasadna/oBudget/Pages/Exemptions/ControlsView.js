import _ from 'underscore';
import Backbone from 'backbone';
import tplControls from 'Hasadna/oBudget/Pages/Exemptions/controls.hbs';
import 'vendor/bootstrap-select';

export default class ControlsView extends Backbone.View {

  className() {
    return 'controls col-sm-12';
  }

  initialize() {
    this.triggerControlsValuesDebounced = _.debounce(this.triggerControlsValues.bind(this), 500);
      // @$el.on("keyup", "[name=free-text]", _.debounce(@triggerControlsValues.bind(@), 500))
    this.listenTo(this.model, 'change:publicationId', this.exemptionSelected);
  }

  events() {
    return {
      'change select#spendings-day-limit': 'triggerControlsValues',
      'change select.ministry': 'triggerControlsValuesDebounced',
      'change select.order-by': 'triggerControlsValues',
      'change [name=asc_desc]': 'triggerControlsValues',
    };
  }

  isMobile() {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent) &&
      !(window.chrome && window.chrome.webstore);
  }

  exemptionSelected() {
    if (window.matchMedia('all and (max-width:768px)').matches) {
      this.$el.find('.controls-header').trigger('click');
    }
  }

  triggerControlsValues() {
    window.setTimeout(() => {
      this.trigger('values', this.getControlsValues());
    });
  }

  getControlsValues() {
    return {
      timeFrame: this.$el.find('select#spendings-day-limit').val() * 1,
      ministry: this.$el.find('select.ministry').val() || [],
      orderBy: this.$el.find('select.order-by').val(),
      orderByDirection: this.$el.find('[name=asc_desc]:checked').val() * 1,
    };
  }

  // freeText: @$el.find('[name=free-text]').val()
  render() {
    const data = {
      ui: this.model.toJSON(),
    };

    this.$el.html(tplControls(data));

    return this.$el.find('select').selectpicker({
      mobile: this.isMobile(),
    });
  }
}
