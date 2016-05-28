import Backbone from 'backbone';
import PieChart from 'Hasadna/oBudget/Pages/Exemptions/EntityViz/PieChart';
import Histogram from 'Hasadna/oBudget/Pages/Exemptions/EntityViz/Histogram';


export default class EntityVizView extends Backbone.View {
  id () {
    return 'entity-viz';
  }

  initialize (options) {
    this.entity = options.entity;

    this.listenTo(
      this.entity,
      'change:procurements',
      (model, procurements) => {
        this.procurements = model.procurements;
        this.render(this.procurements.toJSON());
      });
  }

  render (procurements) {
    PieChart('entity-viz-pie', procurements);
  }
}
