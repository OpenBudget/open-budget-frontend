# Based on code from: https://github.com/vlandham/gates_bubbles
#
# License:
#
# D3.js:
#
# Copyright (c) 2010-2014, Michael Bostock
# All rights reserved.
#
# Copyright (c) 2012-2014, Jim Vallandingham
# All rights reserved.
#
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

MAX_RADIUS = 85

d3.selection.prototype.moveToFront = ->
  this.each( -> this.parentNode.appendChild(this) )

class BubbleChart extends Backbone.View
  initialize: (options) ->
    @options = options

    @width = @$el.width()
    @height = @$el.height()

    @tooltip = d3.tip()
                   .attr('class', 'd3-tip bubble-chart-tip')
                   .direction("n")
                   .offset((d) => [35,0])
                   .html((d) -> d.tooltip_contents())

    # used when setting up force and
    # moving around nodes
    @layout_gravity = -0.01
    @damper = 0.1

    # these will be set in create_nodes and create_vis
    @vis = d3.select(@el)
      .attr("width", @width)
      .attr("height", @height)
      .call(@tooltip)
    @nodes = null

    @force = d3.layout.force()
                .size([@width, @height])
                .gravity(@layout_gravity)
                .charge(this.charge)
                .friction(0.9)
                .on "tick", (e) =>
                    @calc_averages()
                    if not @centeredNode? or not @centeredNode.transformationComplete
                        selection = @circles
                    else
                        selection = @childCircles
                    selection
                      .each(this.move_towards_centers(e.alpha))
                      .attr("cx", (d) =>
                          d.x - @get_offset(e.alpha,d).dx
                      )
                      .attr("cy", (d) =>
                          d.y - @get_offset(e.alpha,d).dy
                      )
                .on "end", (e) =>
                    if @centeredNode? and not @centeredNode.transformationComplete
                        @centeredNode.transformationComplete = true
                        @centeredNode.radius = MAX_RADIUS
                        @vis.select("#bubble_#{@centeredNode.id}")
                            .transition()
                            .duration(1000)
                            .attr("r", (d) -> d.radius)
                            .each 'end',  =>
                                if @options.focusComplete?
                                    @options.focusComplete()
                                @vis.select("#bubble_#{@centeredNode.id}")
                                    .transition()
                                    .duration(1000)
                                    .attr("stroke-dasharray", "5,5")
                                    .style("fill", "transparent")

    @circles = null

  setHeight: (height) ->
      @height = height
      d3.select(@el)
        .attr("height", @height)
      @force.size([@width, @height])

  updateNodes: (data, numParts, centeredNode) ->
    if not @data? or @data.length != data.length
        @data = data

    @numParts = numParts
    # use the max total_amount in the data as the max in the scale's domain
    max_amount = d3.max(@data, (d) -> if d.center.category() != "focused" then d.value else null)
    @total_amount = d3.sum(@data, (d) -> if d.center.category() != "focused" then d.value else null)
    @radius_scale = d3.scale.pow().exponent(0.5).domain([0, max_amount]).range([2, MAX_RADIUS])
    @boundingRadius = @radius_scale(@total_amount/@numParts)

    @centeredNode = centeredNode

    if not @nodes? or @nodes.length != @data.length
        @create_nodes()
        @force.nodes(@nodes)
        @render(true)

  # create node objects from original data
  # that will serve as the data behind each
  # bubble in the vis, then add each node
  # to @nodes to be used later
  create_nodes: () =>
      if not @nodes?
          @nodes = []

      @data.forEach (d) =>
          if @nodes.indexOf(d) is -1
              d.radius = @radius_scale(d.value)
              d.x = if d.x? then d.x else Math.random() * @width
              d.y = if d.y? then d.y else Math.random()*50 - d.part*@boundingRadius + d.center.y
              if d.radius < 0
                  return

              @nodes.push d

      @nodes.sort (a,b) -> b.value - a.value

  # create svg at #vis and then
  # create circle representation for each node
  render: (keepRadius) =>
    @circles = @vis.selectAll("circle")
                    .data(@nodes, (d) -> d.id)

    # used because we need 'this' in the
    # mouse callbacks
    that = this

    # radius will be set to 0 initially.
    # see transition below
    newCircles = @circles.enter().append("circle")
      .attr("stroke-width", 2)
      .attr("id", (d) -> "bubble_#{d.id}")
      .on("click", (d,i) -> d.click())
      .on("mouseover", (d,i) -> that.show_details(d,i,this))
      .on("mouseout", (d,i) -> that.hide_details(d,i,this))

    if not keepRadius
        newCircles.attr("r", 0)

    @reapply_values()

    if @centeredNode?
        @vis.select("#bubble_#{@centeredNode.id}").moveToFront()

    @childCircles = @vis.selectAll(".child-bubble")

  reapply_values: () =>
      # Fancy transition to make bubbles appear, ending with the
      # correct radius
      @circles
          .attr("class", (d) -> d.className())
          .transition().duration(2000).attr("r", (d) -> d.radius)

  # Charge function that is called for each node.
  # Charge is proportional to the diameter of the
  # circle (which is stored in the radius attribute
  # of the circle's associated data.
  # This is done to allow for accurate collision
  # detection with nodes of different sizes.
  # Charge is negative because we want nodes to
  # repel.
  # Dividing by 8 scales down the charge to be
  # appropriate for the visualization dimensions.
  charge: (d) ->
    -Math.pow(d.radius, 2.0) / 8

  # Sets up force layout to display
  # all nodes in one circle.
  start: () =>
    @boundingRadius = @radius_scale(@total_amount/@numParts)
    @force.start()

  calc_averages: () =>
    @averages = {}
    extents = {}
    for d in @nodes
        cat = d.center.category()
        if !extents[cat]?
            extents[cat] =
                maxx: 0
                maxy: 0
                minx: @width
                miny: @height
        extents[cat].maxx = d3.max([extents[cat].maxx,d.x])
        extents[cat].maxy = d3.max([extents[cat].maxy,d.y])
        extents[cat].minx = d3.min([extents[cat].minx,d.x])
        extents[cat].miny = d3.min([extents[cat].miny,d.y])
    for cat in _.keys(extents)
        extent = extents[cat]
        if not @centeredNode? or not @centeredNode.transformationComplete or cat == "focused"
            @averages[cat] =
                x: (extent.maxx + extent.minx)/2
                y: (extent.maxy + extent.miny)/2

  get_offset: (alpha,d) =>
      cat = d.center.category()
      if !@averages[cat]?
          { dx: 0, dy: 0 }
      else
          avg = @averages[cat]
          s = ((0.1-alpha)/0.1)
          {
            dx: s*(avg.x - d.center.x),
            dy: s*(avg.y - d.center.y)
          }

  # Moves all circles towards the @center
  # of the visualization
  move_towards_centers: (alpha) =>
      (d) =>
          d.x = d.x + (d.center.x - d.x) * (@damper + 0.02) * alpha
          targetY =  d.center.y - d3.min([1,d.part]) * @boundingRadius
          d.y = d3.max([0, d.y + (d.center.y - d.y) * (@damper + 0.02) * alpha + (targetY - d.y) * (@damper) * alpha * alpha * alpha * 500])

  show_details: (data, i, element) =>
    d3.select(element)
       .style('stroke-width',4)
       .attr('r',d3.max([0,data.radius-1]))
    $(".bubble-chart-tip").toggleClass('active',true)
    @tooltip.show(data)

  hide_details: (data, i, element) =>
    d3.select(element)
        .style('stroke-width',2)
        .attr('r',data.radius)
    @tooltip.hide(data)
    $(".bubble-chart-tip").toggleClass('active',false)

window.BubbleChart = BubbleChart
