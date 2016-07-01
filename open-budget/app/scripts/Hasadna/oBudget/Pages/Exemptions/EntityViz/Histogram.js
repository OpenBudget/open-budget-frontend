import d3 from 'd3';

function formatValue (value) {
  return value ? d3.format(",")(value.toFixed(2)) : '';
}

/*
 * Lifted from http://bl.ocks.org/NPashaP/96447623ef4d342ee09b
 */
// function to handle histogram
export default function Histogram (element_id, data, options) {
  const barColor = options.colors.total;
  let histogram = {},
      histogram_dims = { t: 30, r: 0, b: 60, l: 0 };

  histogram_dims.w = 500 - histogram_dims.l - histogram_dims.r;
  histogram_dims.h = 400 - histogram_dims.t - histogram_dims.b;

  //create svg for histogram.
  let histogram_svg = d3.select('#' + element_id)
    .append("svg")
    .attr("width", histogram_dims.w + histogram_dims.l + histogram_dims.r)
    .attr("height", histogram_dims.h + histogram_dims.t + histogram_dims.b)
    .append("g")
    .attr("transform", "translate(" + histogram_dims.l + "," + histogram_dims.t + ")");

  // create function for x-axis mapping.
  let x = d3.scale.ordinal().rangeRoundBands([0, histogram_dims.w], 0.1)
    .domain(data.map(function (d) {
      return d.publisher;
    }));

  // Add x-axis to the histogram svg.
  histogram_svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + histogram_dims.h + ")")
    .call(d3.svg.axis()
      .scale(x)
      .orient("bottom"));

  // Create function for y-axis map.
  let y = d3.scale.linear()
    .range([histogram_dims.h, 0])
    .domain([0, d3.max(data, function (d) {
      return d.total;
    })]);

  // Create bars for histogram to contain rectangles and freq labels.
  let bars = histogram_svg.selectAll(".bar").data(data).enter()
    .append("g")
    .attr("class", "bar");

  //create the rectangles.
  bars.append("rect")
    .attr("x", function (d) {
      return x(d.publisher);
    })
    .attr("y", function (d) {
      return y(d.total);
    })
    .attr("width", x.rangeBand())
    .attr("height", function (d) {
      return histogram_dims.h - y(d.total);
    })
    .attr('fill', barColor);

  //Create the value labels above the rectangles.
  bars.append("text")
    .text(function (d) {
      return formatValue(d.total);
    })
    .attr("x", function (d) {
      return x(d.publisher) + x.rangeBand() / 2;
    })
    .attr("y", function (d) {
      return y(d.total) - 5;
    })
    .attr("text-anchor", "middle");

  // create function to update the bars. This will be used by pie-chart.
  histogram.update = function (type, color) {
    // update the domain of the y-axis map to reflect change in values.
    y.domain([0, d3.max(data, function (d) {
      return d.total;
    })]);

    // Attach the new data to the bars.
    let bars = histogram_svg.selectAll(".bar").data(data);

    // transition the height and color of rectangles.
    bars.select("rect").transition().duration(500)
      .attr("y", function (d) {
        return y(d[type]);
      })
      .attr("height", function (d) {
        return histogram_dims.h - y(d[type]);
      })
      .attr("fill", color);

    // transition the value labels location and change value.
    bars.select("text").transition().duration(500)
      .text(function (d) {
        return formatValue(d[type]);
      })
      .attr("y", function (d) {
        return y(d[type]) - 5;
      });
  };

  return histogram;
}
