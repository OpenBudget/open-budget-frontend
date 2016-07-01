import Backbone from 'backbone';
import PieChart from 'Hasadna/oBudget/Pages/Exemptions/EntityViz/PieChart';
import Histogram from 'Hasadna/oBudget/Pages/Exemptions/EntityViz/Histogram';


function parseOrderDate (date) {
  "use strict";
  let split = date.split('/').map((n) => parseInt(n, 10));
  return new Date(split[2], split[1] - 1, split[0]);
}

function orderDateEpoch (proc) {
  "use strict";
  return parseOrderDate(proc.order_date).valueOf();
}

function amountSupportedOrZero (support) {
  "use strict";
  return support.amount_supported || 0;
}

export default class EntityVizView extends Backbone.View {
  id () {
    return 'entity-viz';
  }

  initialize (options) {
    this.entity = options.entity;
    this.render(this.entity.get('procurements'), this.entity.get('supports'));
  }

  render (procurements, supports) {
    const COLORS = {
      total: '#0b587d',
      procurement: "#807dba",
      support: "#FF698C"
    };

    let orders = {},
        histogram_data = {};

    procurements.forEach((proc) => {
      if ( ! (proc.order_id in orders) ) {
        orders[proc.order_id] = [];
      }

      orders[proc.order_id].push(proc);
    });

    // get the latest for each order
    let latest_orders = Object.keys(orders).map((order_id) => {
      return orders[order_id].sort((a, b) => {
        return orderDateEpoch(b) - orderDateEpoch(a);
      })[0];
    });

    let order_volumes = latest_orders.map((order) => order.volume);

    let piechart = PieChart('entity-viz-pie', [
      {
        type: 'procurement',
        value: (order_volumes && order_volumes.length ?
          order_volumes.reduce((a, b) => a + b) : 0)
      },
      {
        type: 'support',
        value: (supports && supports.length ? supports.reduce((a, b) => {
          return amountSupportedOrZero(a) + amountSupportedOrZero(b);
        }) : 0)
      }
    ], { colors: COLORS });

    latest_orders.forEach((order) => {
      if ( ! (order.report_publisher in histogram_data) ) {
        histogram_data[order.report_publisher] = [];
      }

      histogram_data[order.report_publisher].push({
        type: 'procurement',
        value: order.volume || 0
      });
    });

    supports.forEach((support) => {
      if ( ! (support.subject in histogram_data) ) {
        histogram_data[support.subject] = [];
      }

      histogram_data[support.subject].push({
        type: 'support',
        value: amountSupportedOrZero(support)
      });
    });

    histogram_data = Object.keys(histogram_data).map((publisher) => {
      let total = 0, procurement = 0, support = 0;

      histogram_data[publisher].forEach((datum) => {
        if ( datum.type === 'support') {
          support += datum.value;
        }
        else if ( datum.type === 'procurement') {
          procurement += datum.value;
        }
        total += datum.value;
      });

      return {
        publisher: publisher,
        support: support,
        procurement: procurement,
        total: total
      };
    });

    piechart.histogram = Histogram('entity-viz-histogram', histogram_data, { colors: COLORS });
  }
}
