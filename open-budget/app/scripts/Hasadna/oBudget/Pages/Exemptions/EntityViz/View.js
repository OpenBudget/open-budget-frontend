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
    this.render(this.entity.get('procurements'), this.entity.get('supports'));
  }

  render(procurements, supports) {
    const COLORS = {
      total: '#0b587d',
      procurement: '#807dba',
      support: '#FF698C',
    };
    const orders = {};
    let histogramData = {};

    procurements.forEach((proc) => {
      if (! (proc.order_id in orders)) {
        orders[proc.order_id] = [];
      }

      orders[proc.order_id].push(proc);
    });

    // get the latest for each order
    const latestOrders = Object.keys(orders)
        .map((orderId) => orders[orderId].sort((a, b) => orderDateEpoch(b) - orderDateEpoch(a))[0]);

    const orderVolumes = latestOrders.map((order) => order.volume);

    const piechart = pieChart('entity-viz-pie', [
      {
        type: 'procurement',
        value: (orderVolumes && orderVolumes.length ?
          orderVolumes.reduce((a, b) => a + b) : 0),
      },
      {
        type: 'support',
        value: (supports && supports.length ? supports
            .reduce((a, b) => amountSupportedOrZero(a) + amountSupportedOrZero(b)) : 0),
      },
    ], { colors: COLORS });

    latestOrders.forEach((order) => {
      if (! (order.report_publisher in histogramData)) {
        histogramData[order.report_publisher] = [];
      }

      histogramData[order.report_publisher].push({
        type: 'procurement',
        value: order.volume || 0,
      });
    });

    supports.forEach((support) => {
      if (! (support.subject in histogramData)) {
        histogramData[support.subject] = [];
      }

      histogramData[support.subject].push({
        type: 'support',
        value: amountSupportedOrZero(support),
      });
    });

    histogramData = Object.keys(histogramData).map((publisher) => {
      let total = 0;
      let procurement = 0;
      let support = 0;

      histogramData[publisher].forEach((datum) => {
        if (datum.type === 'support') {
          support += datum.value;
        } else if (datum.type === 'procurement') {
          procurement += datum.value;
        }
        total += datum.value;
      });

      return {
        publisher,
        support,
        procurement,
        total,
      };
    });

    piechart.histogram = histogram('entity-viz-histogram', histogramData, { colors: COLORS });
  }
}
