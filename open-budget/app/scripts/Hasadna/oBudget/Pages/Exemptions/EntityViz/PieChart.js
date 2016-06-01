import d3 from 'd3';


/*
 * Lifted from http://bl.ocks.org/NPashaP/96447623ef4d342ee09b
 */

function segColor (c) {
  return { procurements: "#807dba", supports: "#e08214" }[c];
}

// function to handle pieChart.
export default function PieChart (element_id, data) {
  let pC = {},
    pieDim = { w: 250, h: 250 };

  pieDim.r = Math.min(pieDim.w, pieDim.h) / 2;

  // create svg for pie chart.
  let piesvg = d3.select('#' + element_id)
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
  piesvg.selectAll("path")
    .data(pie(data))
    .enter()
    .append("path")
    .attr("d", arc)
    .each(function (d) {
      this._current = d;
    })
    .style("fill", (d) => {
      return segColor(d.data.type);
    });
  /*.on("mouseover", mouseover).on("mouseout", mouseout);*/

  // create function to update pie-chart. This will be used by histogram.
  pC.update = function (nD) {
    piesvg.selectAll("path")
      .data(pie(nD))
      .transition()
      .duration(500)
      .attrTween("d", arcTween);
  };

  /*
   // Utility function to be called on mouseover a pie slice.
   function mouseover (d) {
   // call the update function of histogram with new data.
   hG.update(fData.map(function (v) {
   return [v.State, v.freq[d.data.type]];
   }), segColor(d.data.type));
   }

   //Utility function to be called on mouseout a pie slice.
   function mouseout (d) {
   // call the update function of histogram with all data.
   hG.update(fData.map(function (v) {
   return [v.State, v.total];
   }), barColor);
   }
   */

  // Animating the pie-slice requiring a custom function which specifies
  // how the intermediate paths should be drawn.
  function arcTween (a) {
    let i = d3.interpolate(this._current, a);
    this._current = i(0);
    return (t) => {
      return arc(i(t));
    };
  }

  return pC;
}
