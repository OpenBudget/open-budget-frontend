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
    this.render(this.entity.get('procurements'));
  }

  render (procurements) {
    let orders = {};

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

    let supports = this.entity.get('supports');

    PieChart('entity-viz-pie', [
      {
        type: 'procurements',
        value: (order_volumes && order_volumes.length ?
          order_volumes.reduce((a, b) => {
            return a + b;
          }) : 0)
      },
      {
        type: 'supports',
        value: (supports && supports.length ? supports.reduce((a, b) => {
          return amountSupportedOrZero(a) + amountSupportedOrZero(b);
        }) : 0)
      }
    ]);

    let orders_by_publisher = {};

    latest_orders.forEach((order) => {
      if ( ! (orders_by_publisher.publisher in orders_by_publisher) ) {
        orders_by_publisher[order.publisher] = [];
      }

      orders_by_publisher[order.publisher].push(order.volume || 0);
    });

    let histogram_data = Object.keys(orders_by_publisher).map((publisher) => {
      return {
        publisher: publisher,
        value: orders_by_publisher[publisher].reduce((a, b) => {
          return a + b;
        })
      };
    });

    Histogram('entity-viz-histogram', histogram_data);
  }
}
