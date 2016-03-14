import Backbone from 'backbone';
import template from 'Hasadna/oBudget/Pages/BudgetItem/template.hbs';

export default class View extends Backbone.View {
  render() {
    this.$el.html(template());
  }
}
