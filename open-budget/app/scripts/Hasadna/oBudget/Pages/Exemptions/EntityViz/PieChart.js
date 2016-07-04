import d3 from 'd3';


/*
 * Lifted from http://bl.ocks.org/NPashaP/96447623ef4d342ee09b
 */

function getSegmentColorFactory (colors) {
  "use strict";
  return function (c) {
    return colors[c];
  };
}

// function to handle pieChart.
export default function PieChart (element_id, data, options) {
  let getSegmentColor = getSegmentColorFactory(options.colors),
    piechart = {},
    pieDim = { w: 250, h: 250 };

  // Utility function to be called on mouseover a pie slice.
  function mouseover (d) {
    if ( piechart.histogram ) {
      // call the update function of histogram with new data.
      piechart.histogram.update(d.data.type, getSegmentColor(d.data.type));
    }
  }

  //Utility function to be called on mouseout a pie slice.
  function mouseout (d) {
    if ( piechart.histogram ) {
      // call the update function of histogram with all data.
      piechart.histogram.update('total', getSegmentColor('total'));
    }
  }


  // Animating the pie-slice requiring a custom function which specifies
  // how the intermediate paths should be drawn.
  function arcTween (a) {
    let i = d3.interpolate(this._current, a);
    this._current = i(0);
    return (t) => {
      return arc(i(t));
    };
  }

  pieDim.r = Math.min(pieDim.w, pieDim.h) / 2;

  // create svg for pie chart.
  let pie_svg = d3.select('#' + element_id)
    .append("svg")
    .attr("width", pieDim.w)
    .attr("height", pieDim.h)
    .append("g")
    .attr("transform", "translate(" + pieDim.w / 2 + "," + pieDim.h / 2 + ")");

  // create function to draw the arcs of the pie slices.
  let arc = d3.svg.arc().outerRadius(pieDim.r - 10).innerRadius(0);

  // create a function to compute the pie slice angles.
  let pie = d3.layout.pie()
    .sort(null)
    .value(function (d) {
      return d.value;
    });

  // Draw the pie slices.
  pie_svg.selectAll("path")
    .data(pie(data))
    .enter()
    .append("path")
    .attr("d", arc)
    .each(function (d) {
      this._current = d;
    })
    .style("fill", (d) => {
      return getSegmentColor(d.data.type);
    })
    .on("mouseover", mouseover).on("mouseout", mouseout);

  // create function to update pie-chart. This will be used by histogram.
  piechart.update = function (nD) {
    pie_svg.selectAll("path")
      .data(pie(nD))
      .transition()
      .duration(500)
      .attrTween("d", arcTween);
  };

  return piechart;
}
