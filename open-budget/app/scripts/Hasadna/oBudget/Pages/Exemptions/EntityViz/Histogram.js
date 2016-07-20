import d3 from 'd3';

function formatValue(value) {
  return value ? d3.format(',')(value.toFixed(2)) : '';
}

/*
 * Lifted from http://bl.ocks.org/NPashaP/96447623ef4d342ee09b
 */
// function to handle histogram
export default function Histogram(elementId, data, options) {
  const barColor = options.colors.total;
  const histogram = {};
  const histogramDims = { t: 30, r: 0, b: 60, l: 0 };

  histogramDims.w = 500 - histogramDims.l - histogramDims.r;
  histogramDims.h = 400 - histogramDims.t - histogramDims.b;

  // create svg for histogram.
  const histogramSvg = d3.select(`#${elementId}`)
    .append('svg')
    .attr('width', histogramDims.w + histogramDims.l + histogramDims.r)
    .attr('height', histogramDims.h + histogramDims.t + histogramDims.b)
    .append('g')
    .attr('transform', `translate(${histogramDims.l},${histogramDims.t})`);

  // create function for x-axis mapping.
  const x = d3.scale.ordinal().rangeRoundBands([0, histogramDims.w], 0.1)
    .domain(data.map((d) => d.publisher));

  // Add x-axis to the histogram svg.
  histogramSvg.append('g')
    .attr('class', 'x axis')
    .attr('transform', `translate(0,${histogramDims.h})`)
    .call(d3.svg.axis()
      .scale(x)
      .orient('bottom'));

  // Create function for y-axis map.
  const y = d3.scale.linear()
    .range([histogramDims.h, 0])
    .domain([0, d3.max(data, (d) => d.total)]);

  // Create bars for histogram to contain rectangles and freq labels.
  let bars = histogramSvg.selectAll('.bar').data(data).enter()
    .append('g')
    .attr('class', 'bar');

  // create the rectangles.
  bars.append('rect')
    .attr('x', (d) => x(d.publisher))
    .attr('y', (d) => y(d.total))
    .attr('width', x.rangeBand())
    .attr('height', (d) => histogramDims.h - y(d.total))
    .attr('fill', barColor);

  // Create the value labels above the rectangles.
  bars.append('text')
    .text((d) => formatValue(d.total))
    .attr('x', (d) => x(d.publisher) + x.rangeBand() / 2)
    .attr('y', (d) => y(d.total) - 5)
    .attr('text-anchor', 'middle');

  // create function to update the bars. This will be used by pie-chart.
  histogram.update = function update(type, color) {
    // update the domain of the y-axis map to reflect change in values.
    y.domain([0, d3.max(data, (d) => d.total)]);

    // Attach the new data to the bars.
    bars = histogramSvg.selectAll('.bar').data(data);

    // transition the height and color of rectangles.
    bars.select('rect').transition().duration(500)
      .attr('y', (d) => y(d[type]))
      .attr('height', (d) => histogramDims.h - y(d[type]))
      .attr('fill', color);

    // transition the value labels location and change value.
    bars.select('text').transition().duration(500)
      .text((d) => formatValue(d[type]))
      .attr('y', (d) => y(d[type]) - 5);
  };

  return histogram;
}
