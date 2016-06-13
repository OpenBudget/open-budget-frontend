import d3 from 'd3';


/*
 * Lifted from http://bl.ocks.org/NPashaP/96447623ef4d342ee09b
 */
// function to handle histogram
export default function Histogram(elementId, data) {
  const barColor = 'steelblue';
  const hG = {};
  const hGDim = { t: 30, r: 0, b: 60, l: 0 };

  hGDim.w = 500 - hGDim.l - hGDim.r;
  hGDim.h = 400 - hGDim.t - hGDim.b;

  // create svg for histogram.
  const hGsvg = d3.select(`#${elementId}`)
    .append('svg')
    .attr('width', hGDim.w + hGDim.l + hGDim.r)
    .attr('height', hGDim.h + hGDim.t + hGDim.b)
    .append('g')
    .attr('transform', `translate(${hGDim.l}, ${hGDim.t})`);

  // create function for x-axis mapping.
  const x = d3.scale.ordinal().rangeRoundBands([0, hGDim.w], 0.1)
    .domain(data.map((d) => d.publisher));

  // Add x-axis to the histogram svg.
  hGsvg.append('g')
    .attr('class', 'x axis')
    .attr('transform', `translate(0, ${hGDim.h})`)
    .call(d3.svg.axis()
      .scale(x)
      .orient('bottom'));

  // Create function for y-axis map.
  const y = d3.scale.linear()
    .range([hGDim.h, 0])
    .domain([0, d3.max(data, (d) => d.value)]);

  // Create bars for histogram to contain rectangles and freq labels.
  const bars = hGsvg.selectAll('.bar').data(data).enter()
    .append('g')
    .attr('class', 'bar');

  // create the rectangles.
  bars.append('rect')
    .attr('x', (d) => x(d.publisher))
    .attr('y', (d) => y(d.value))
    .attr('width', x.rangeBand())
    .attr('height', (d) => hGDim.h - y(d.value))
    .attr('fill', barColor);

  // Create the value labels above the rectangles.
  bars.append('text')
    .text((d) => d3.format(',')(d.value))
    .attr('x', (d) => x(d.publisher) + x.rangeBand() / 2)
    .attr('y', (d) => y(d.value) - 5)
    .attr('text-anchor', 'middle');

  // create function to update the bars. This will be used by pie-chart.
  hG.update = (nD, color) => {
    // update the domain of the y-axis map to reflect change in values.
    y.domain([0, d3.max(nD, (d) => d.value)]);

    // Attach the new data to the bars.
    const bars2 = hGsvg.selectAll('.bar').data(nD);

    // transition the height and color of rectangles.
    bars2.select('rect').transition().duration(500)
      .attr('y', (d) => y(d.value))
      .attr('height', (d) => hGDim.h - y(d.value))
      .attr('fill', color);

    // transition the value labels location and change value.
    bars2.select('text').transition().duration(500)
      .text((d) => d3.format(',')(d.value))
      .attr('y', (d) => y(d.value) - 5);
  };

  return hG;
}
