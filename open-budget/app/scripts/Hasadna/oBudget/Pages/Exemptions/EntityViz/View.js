import Backbone from 'backbone';
import d3 from 'd3';
import Procurements from 'Hasadna/oBudget/Pages/Exemptions/DataStruct/Procurements';
import PieChart from 'Hasadna/oBudget/Pages/Exemptions/EntityViz/PieChart';
import Histogram from 'Hasadna/oBudget/Pages/Exemptions/EntityViz/Histogram';


export default class EntityVizView extends Backbone.View {
  id () {
    return 'entity-viz';
  }

  initialize (options) {
    this.procurements = new Procurements(null, options);

    this.procurements.fetch().then((response) => {
      this.render(response);
    });
  }

  render (response) {
    var freqData=[
      {State:'AL',freq:{low:4786, mid:1319, high:249}}
      ,{State:'AZ',freq:{low:1101, mid:412, high:674}}
      ,{State:'CT',freq:{low:932, mid:2149, high:418}}
      ,{State:'DE',freq:{low:832, mid:1152, high:1862}}
      ,{State:'FL',freq:{low:4481, mid:3304, high:948}}
      ,{State:'GA',freq:{low:1619, mid:167, high:1063}}
      ,{State:'IA',freq:{low:1819, mid:247, high:1203}}
      ,{State:'IL',freq:{low:4498, mid:3852, high:942}}
      ,{State:'IN',freq:{low:797, mid:1849, high:1534}}
      ,{State:'KS',freq:{low:162, mid:379, high:471}}
    ];
    // calculate total frequency by segment for all state.
    var tF = ['low','mid','high'].map((d) => {
        return {
          type:d,
          freq: d3.sum(freqData.map((t) => { return t.freq[d];}))
        };
    });

    PieChart(this.id(), tF);
  }
}
