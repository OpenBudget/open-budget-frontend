import Backbone from 'backbone';
import pieChart from 'Hasadna/oBudget/Pages/Exemptions/EntityViz/PieChart';
import histogram from 'Hasadna/oBudget/Pages/Exemptions/EntityViz/Histogram';


function parseOrderDate(date) {
  'use strict';
  const split = date.split('/').map((n) => parseInt(n, 10));
  return new Date(split[2], split[1] - 1, split[0]);
}

function orderDateEpoch(proc) {
  'use strict';
  return parseOrderDate(proc.order_date).valueOf();
}

function amountSupportedOrZero(support) {
  'use strict';
  return support.amount_supported || 0;
}

export default class EntityVizView extends Backbone.View {
  id() {
    return 'entity-viz';
  }

  initialize(options) {
    this.entity = options.entity;
    this.render(this.entity.get('procurements'));
  }

  render(procurements) {
    const orders = {};

    procurements.forEach((proc) => {
      if (! (proc.order_id in orders)) {
        orders[proc.order_id] = [];
      }

      orders[proc.order_id].push(proc);
    });

    // get the latest for each order
    const latestOrders = Object.keys(orders).map((orderId) => {
      const tmp1 = orders[orderId].sort((a, b) => {
        const tmp = orderDateEpoch(b) - orderDateEpoch(a);
        return tmp;
      })[0];

      return tmp1;
    });

    const orderVolumes = latestOrders.map((order) => order.volume);

    const supports = this.entity.get('supports');

    pieChart('entity-viz-pie', [
      {
        type: 'procurements',
        value: (orderVolumes && orderVolumes.length ?
          orderVolumes.reduce((a, b) => a + b) : 0),
      },
      {
        type: 'supports',
        value: (supports && supports.length ?
           supports.reduce((a, b) => amountSupportedOrZero(a) + amountSupportedOrZero(b)) :
            0),
      },
    ]);

    const ordersByPublisher = {};

    latestOrders.forEach((order) => {
      if (! (ordersByPublisher.publisher in ordersByPublisher)) {
        ordersByPublisher[order.publisher] = [];
      }

      ordersByPublisher[order.publisher].push(order.volume || 0);
    });

    const histogramData = Object.keys(ordersByPublisher).map((publisher) => {
      const tmp = {
        publisher,
        value: ordersByPublisher[publisher].reduce((a, b) => a + b),
      };

      return tmp;
    });

    histogram('entity-viz-histogram', histogramData);
  }
}
