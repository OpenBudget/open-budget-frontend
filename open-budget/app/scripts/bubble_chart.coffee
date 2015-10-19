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

define(['backbone', 'd3', 'd3-tip'], (Backbone, d3, d3tip) ->
    MAX_RADIUS = 85
    DURATION = 1000

    MIDDLE = 300

    # When loading the scripts as AMD modules d3-tip does not assigns itself
    # to d3.tip
    d3.tip = d3tip

    d3.selection.prototype.moveToFront = ->
      this.each( -> this.parentNode.appendChild(this))

    d3.selection.prototype.sendToBack = ->
      this.each( -> $(this).parent().prepend(this))

    class BubbleChart extends Backbone.View
      initialize: (options) ->
        @options = options

        @width = @$el.width()
        @height = @$el.height()
        @range = [0, MAX_RADIUS]

        @circles = d3.select()
        @childCircles = d3.select()

        @centerNodeQueue = []
        @tooltip = d3.tip()
                       .attr('class', 'd3-tip bubble-chart-tip')
                       .direction("n")
                       .offset((d) => [35,0])
                       .html((d) -> d.tooltip_contents())

        @circleLegendOpacity = 1

        # used when setting up force and
        # moving around nodes
        @layout_gravity = -0.01
        @damper = 0.1

        # these will be set in create_nodes and create_vis
        @vis = d3.select(@el)
          .attr("width", @width)
          .attr("height", @height)

        @createFilter()

        @vis.call(@tooltip)
        @nodes = null

        @buildLayoutForceObject()

        @circles = null

      createFilter: () ->
          # Define the shadow filter
          @filter = @vis.append("defs")
            .append("filter")
              .attr("id", "shadow")
              .attr("width", "200%")
              .attr("height", "200%")
              .attr("x", "-50%")
              .attr("y", "-50%")
          # Dilate (expand) the input image
          @filter.append("feMorphology")
              .attr("in", "SourceAlpha")
              .attr("operator", "dilate")
              .attr("radius", 1)
              .attr("result", "dilatedSource")
          # ComponentTransfer will allow changing the color of the shadow
          feComponentTransfer = @filter.append("feComponentTransfer")
              .attr("in", "dilatedSource")
              .attr("result", "recolored")
          @feFuncR = feComponentTransfer.append("feFuncR")
              .attr("type", "discrete")
          @feFuncG = feComponentTransfer.append("feFuncG")
              .attr("type", "discrete")
          @feFuncB = feComponentTransfer.append("feFuncB")
              .attr("type", "discrete")
          @shadowColor("rgb(0, 0, 0)")

          # Add blur
          @filter.append("feGaussianBlur")
              .attr("in", "recolored")
              .attr("stdDeviation", 5)
              .attr("result", "blur")
          # Add offset
          @filter.append("feOffset")
              .attr("in", "blur")
              .attr("dx", 0)
              .attr("dy", 0)
              .attr("result", "offsetBlur")
          feMerge = @filter.append("feMerge")
          # Merge the input and the shadow
          feMerge.append("feMergeNode")
              .attr("in", "offsetBlur")
          feMerge.append("feMergeNode")
              .attr("in", "SourceGraphic")

      colorRegex = /rgb\((\d+),\s+(\d+),\s+(\d+)\)/
      shadowColor: (colorString) ->
          color = colorRegex.exec(colorString)
          if color.length == 4
              @feFuncR
                .attr("tableValues", parseInt(color[1])/255)
              @feFuncG
                .attr("tableValues", parseInt(color[2])/255)
              @feFuncB
                .attr("tableValues", parseInt(color[3])/255)

      buildLayoutForceObject: (d) ->
          @force = d3.layout.force()
                      .size([@width, @height])
                      .gravity(@layout_gravity)
                      .charge(this.charge)
                      .friction(0.9)
                      .on "tick", (e) =>
                          @calc_averages()
                          @circles
                            .each(this.move_towards_centers(e.alpha))
                            .attr("cx", (d) =>
                                offset = @get_offset(e.alpha,d).dx
                                d.x - offset
                            )
                            .attr("cy", (d) =>
                                offset = @get_offset(e.alpha,d).dy
                                d.y - offset
                            )
          that = @
          @subNodeForce = d3.layout.force()
                      .size([85, 85])
                      .gravity(@layout_gravity)
                      .charge(this.charge)
                      .friction(0.9)
                      .alpha(1)
                      .on "tick", (e) =>
                          alpha = e.alpha
                          @calc_averages()
                          @childCircles
                            .each(this.move_towards_centers(alpha))
                            .attr("cx", (d) =>
                                offset = @get_offset(alpha,d).dx
                                d.x - offset
                            )
                            .attr("cy", (d) =>
                                offset = @get_offset(alpha,d).dy
                                d.y - offset
                            )

      setHeight: (height) ->
          @height = height
          d3.select(@el)
            .attr("height", @height)
          @force.size([@width, @height])

      revertCenteredNode: (node) ->
          if node?
              node.center = node.origCenter || node.center
              @buildLayoutForceObject()
              node.forceCenter = false
              @vis.select("#bubble_#{node.id}")
                  .transition().duration(DURATION)
                  .attr("stroke-dasharray", null)
                  .attr("fill-opacity", null)
                  .style("pointer-events", null)
                  .attr("r", (d) -> d.radius())
                  .style("filter", null)

      updateFocusCenter: (focusCenter) ->
          @mainFocusCenter = $.extend({}, focusCenter)
          @mainFocusCenter.category = -> "mainFocus"
          @focusCenter = $.extend({}, focusCenter)
        #   @focusCenter.x = @width / 2 - 42.5
        #   @focusCenter.y = 300
          @focusCenter.category = -> "focused"

      replaceCenteredNode: (node, doNotQueue) ->
          if node?
              node.forceCenter = true
              node.origCenter = node.center
              node.center = @focusCenter
              #if @centeredNode? and @centeredNode != node and !doNotQueue
              #     @centerNodeQueue.push(@centeredNode)

          @revertCenteredNode(@centeredNode)
          @centeredNode = node



      focusOnCode: (code) ->
          @focusOnNode(@vis.select("#bubble_#{code}").datum())

      focusOnNode: (d) =>
          # 8 digit codes (2 leading zeros) have no kids
          # subNodes should not be centered
          if d?
            #   if d.id.length >= 10 or d.subNode then return
              if typeof d.click == "function" then d.click.call(d, d)
              @options.stateChange.call(null, "centered", d)

          @replaceCenteredNode(d)

          @vis.selectAll(".child-bubble").remove()
          if @subNodes?
              for subNode in @subNodes
                  index = @data.indexOf(subNode)
                  if index > -1
                      @data.splice(index, 1)

          if @centeredNode?
              @options.addSubNodes(@centeredNode, @subNodesReady)
              @start()
          else
              @updateNodes(@data, @numParts, @centeredNode, true)
              @start()

      updateRadiusScale: () ->
          # use the max total_amount in the data as the max in the scale's domain
          @max_amount = d3.max(@data, (d) -> if !d.subNode then d.value else null)
          @total_amount = d3.sum(@data, (d) -> if !d.subNode then d.value else null)

          @radius_scale = d3.scale.sqrt().domain([0, @max_amount]).range(@range)
          @boundingRadius = @radius_scale(@total_amount/@numParts)

          if @centeredNode?
              targetMax = @centeredNode.value
              newSpan = (@range[1] - @range[0])/Math.sqrt(targetMax)/Math.sqrt(@max_amount)*@max_amount
              newRange = [@range[0], (@range[0] + newSpan)]
              @radius_scale_center = d3.scale.sqrt().domain([0, @max_amount]).range(newRange)

      updateNodes: (data, numParts, centeredNode, forceCreate) ->
        if not @data? or @data != data
            @data = data

        @numParts = numParts
        @updateRadiusScale()

        console.log("boundingRadius: #{@boundingRadius}, Max amount: #{@max_amount}, total amount: #{@total_amount}")

        if not @nodes? or @nodes.length != @data.length or forceCreate
            @nodes = []
            @create_nodes(@data, @nodes)
            @force.nodes(@nodes)
            @render(@nodes, 'circles', true)

      # create node objects from original data
      # that will serve as the data behind each
      # bubble in the vis, then add each node
      # to @nodes to be used later
      create_nodes: (data, nodes) =>
          that = @
          data.forEach (d, i) =>
              if nodes.indexOf(d) is -1
                  d.radius = () ->
                      radius = that.radius_scale(@value)
                      if that.centeredNode? and d.subNode
                          radius * MAX_RADIUS / that.radius_scale(that.centeredNode.value)
                      else if that.centeredNode == @
                          MAX_RADIUS
                      else
                          radius

                  if d.center.category() == "focused"
                      d.x = d.center.x
                      d.y = d.center.y
                  else
                      d.x = if d.x? then d.x else Math.random() * @width
                      d.y = if d.y? then d.y else Math.random()*50 - d.part*@boundingRadius + d.center.y

                  if d.radius() < 0
                      return

                  nodes.push d

          @rendered = true
          @nodes.sort (a,b) -> b.value - a.value

      renderLegend: (maxValue, scalingFunction) ->
          if (maxValue > @legendMaxValue)
              maxStartRadius = 120
              maxEndRadius = 0
          else
              maxStartRadius = 0
              maxEndRadius = 120

          @legendMaxValue = maxValue
          legendData = [
              {value: maxValue*0.35, factor: 1},
              {value: maxValue*0.35, factor: 0.5},
              {value: maxValue*0.35, factor: 0.25}
          ]
          matureLegend = @vis.selectAll(".mature-circle")
                .attr("opacity", 1)
                .transition()
                .duration(DURATION)
                .attr("r", (d) -> maxEndRadius*d.factor)
                .attr("cx", (d) => @width - MAX_RADIUS - 4)
                .attr("cy", (d) => MIDDLE - maxEndRadius*d.factor)
                .attr("opacity", 0)
                .each("end", () -> d3.select(@).remove())

          matureLegend = @vis.selectAll(".mature-line")
                .attr("opacity", 1)
                .transition()
                .duration(DURATION)
                .attr("y1", (d) => MIDDLE - 2*maxEndRadius*d.factor)
                .attr("y2", (d) => MIDDLE - 2*maxEndRadius*d.factor)
                .attr("x2", (d) => @width - scalingFunction(maxValue) - 4 - scalingFunction(maxValue))
                .attr("opacity", 0)
                .each("end", () -> d3.select(@).remove())

          matureLegend = @vis.selectAll(".mature-text")
                .attr("opacity", 1)
                .transition()
                .duration(DURATION)
                .attr("y", (d) => MIDDLE - 2*maxEndRadius*d.factor)
                .attr("x", (d) => @width - scalingFunction(maxValue) - 4 - scalingFunction(maxValue))
                .attr("opacity", 0)
                .each("end", () -> d3.select(@).remove())

          legendCircles = @vis.selectAll(".legend-circle").data(legendData)
          legendCircles.enter().append("circle")
              .attr("stroke-width", 1)
              .attr("stroke", "#9b9b9b")
              .attr("fill", "transparent")
              .attr("class", "legend-circle legend")
          legendCircles
              .attr("r", (d) -> maxStartRadius*d.factor)
              .attr("cy", (d) => MIDDLE - maxStartRadius*d.factor)
              .attr("opacity", 0)
              .transition().duration(DURATION)
              .attr("r", (d) => scalingFunction(d.value*d.factor))
              .attr("cx", (d) => @width - scalingFunction(maxValue) - 4)
              .attr("cy", (d) => MIDDLE - scalingFunction(d.value*d.factor))
              .attr("opacity", @circleLegendOpacity)
              .each("end", (d) ->
                  d3.select(@)
                    .classed("mature-circle", true)
                    .classed("mature-legend", true)
                    .classed("legend-circle", false))
          legendLines = @vis.selectAll(".legend-line").data(legendData)
          legendLines.enter().append("line")
              .attr("stroke-width", 1)
              .attr("stroke", "#9b9b9b")
              .attr("class", "legend-line legend")
              .attr("transform", @circleLegendTransform)
          legendLines
              .attr("x1", (d) => @width - scalingFunction(maxValue) - 4)
              .attr("x2", (d) => @width - 2*scalingFunction(maxValue) - 4)
              .attr("y1", (d) => MIDDLE - 2*maxStartRadius*d.factor)
              .attr("y2", (d) => MIDDLE - 2*maxStartRadius*d.factor)
              .attr("opacity", 0)
              .transition().duration(DURATION)
              .attr("y1", (d) => MIDDLE - 2*scalingFunction(d.value*d.factor))
              .attr("y2", (d) => MIDDLE - 2*scalingFunction(d.value*d.factor))
              .attr("x2", (d) => @width - 2*scalingFunction(maxValue) - 4)
              .attr("opacity", @circleLegendOpacity)
              .each("end", (d) ->
                  d3.select(@)
                    .classed("mature-line", true)
                    .classed("mature-legend", true)
                    .classed("legend-line", false))
          legendText = @vis.selectAll(".legend-text").data(legendData)
          legendText.enter().append("text")
              .style("fill", "#9b9b9b")
              .attr("class", "legend-text legend")
              .attr("font-size", "12px")
              .attr("transform", @circleLegendTransform)
          legendText
              .attr("opacity", 0)
              .attr("x", (d) => @width - 2*scalingFunction(maxValue) - 4)
              .attr("y", (d) => MIDDLE - 2*maxStartRadius*d.factor)
              .text((d) -> window.format_number(d.value*d.factor, false, false, false))
              .transition().duration(DURATION)
              .attr("opacity", @circleLegendOpacity)
              .attr("y", (d) => MIDDLE - 2*scalingFunction(d.value*d.factor))
              .attr("x", (d) => @width - 2*scalingFunction(maxValue) - 4)
              .each("end", (d) ->
                  d3.select(@)
                    .classed("mature-text", true)
                    .classed("mature-legend", true)
                    .classed("legend-text", false))

          colorLegend = @vis.selectAll(".color-legend-box").data(window.changeClassThreshold)
          colorLegend.enter().append("rect")
                .attr("x", 20)
                .attr("y", (d) => MIDDLE + 20*(window.changeClassThreshold.indexOf(d) - window.changeClassThreshold.length/2))
                .attr("width", 8)
                .attr("height", 20)
                .attr("class", (d) -> "color-legend-box color-legend "+d.class+"_svg")

          colorLegendText = @vis.selectAll(".color-legend-text").data(window.changeClassThreshold)
          colorLegendText.enter().append("text")
                .text((d) ->
                    if d.legend == "min"
                        change = d.minRatio - 1
                    else if d.legend == "max"
                        change = d.maxRatio - 1
                    else
                        return "ללא שינוי"

                    if change == 0 then return ""

                    sign = if change > 0 then "+" else ""
                    "#{sign}#{Math.round(change*100)}%"
                    )
                .attr("class", "color-legend-text color-legend")
                .attr("text-anchor", "start")
                .style("direction", "ltr")
                .style("font-size", "12px")
                .style("fill", "#9b9b9b")
                .style("dominant-baseline", "mathematical")
                .attr("x", 35)
                .attr("y", (d) =>
                    y = MIDDLE + 20*(window.changeClassThreshold.indexOf(d) - window.changeClassThreshold.length/2)

                    if (d.legend == "min")
                        y += 20
                    else if (d.legend == "center")
                        y += 10

                    y
                    )

      # create svg at #vis and then
      # create circle representation for each node
      render: (nodes, group, keepRadius) =>
        @[group] = @vis.selectAll(".bubblesCircle")
                        .data(nodes, (d) -> d.id)

        if @centeredNode?
            maxValue = @centeredNode.value
            scaleFunction = @radius_scale_center
        else
            maxValue = @max_amount
            scaleFunction = @radius_scale
        @renderLegend(maxValue, scaleFunction)

        actionButtons = [
            {content: ">", class: "main-vis-back-button", location: {x: @width/4, y: MIDDLE}},
            {content: "+", class: "main-vis-zoom-button", location: {x: @width/2, y: MIDDLE*1.5}}
        ]
        @actionButtons = @vis.selectAll(".main-vis-action-buttons").data(actionButtons)
        @actionButtons.enter()
            .append("text")
            .attr("text-anchor", "middle")
            .attr("class", (d) -> "main-vis-action-buttons #{d.class}")
            .attr("x", (d) -> d.location.x)
            .attr("y", (d) -> d.location.y)
            .text((d) -> d.content)
            .on("click", (d) =>
                if d.class == "main-vis-back-button"
                    if typeof @options.stateChange == "function"
                        @options.stateChange.call(null, "initial")

                    if @centerNodeQueue.length > 0
                        newCenterNode = @centerNodeQueue.splice(0, 1)[0]
                    else
                        newCenterNode = null
                        @vis.selectAll(".main-vis-action-buttons").transition().duration(DURATION).style("opacity", 0)

                    @hide_details()
                    @focusOnNode(newCenterNode)

                else if d.class == "main-vis-zoom-button"
                    @centeredNode.onMoreInfo()
            )

        # used because we need 'this' in the
        # mouse callbacks
        that = this

        # radius will be set to 0 initially.
        # see transition below
        newCircles = @[group].enter().append("circle")
          .attr("stroke-width", 2)
          .attr("id", (d) -> "bubble_#{d.id}")
          .style("display", (d) ->
              if d.subNode
                  "none"
              else
                  ""
            )
          .on("click", @focusOnNode)
          .on("mouseover", (d,i) -> that.show_details(d,i,this))
          .on("mouseout", (d,i) -> that.hide_details())

        if not keepRadius
            newCircles.attr("r", 0)

        @reapply_values()

        if @centeredNode?
            @vis.select("#bubble_#{@centeredNode.id}").sendToBack()

        #@childCircles = @vis.selectAll(".child-bubble")

      toggleColorLegend: (show) =>
          if show
              @vis.selectAll(".color-legend").transition().duration(DURATION).attr("transform","translate(0, 0)")
          else
              @vis.selectAll(".color-legend").transition().duration(DURATION).attr("transform","translate(-100, 0)")
        #
        #   @vis.selectAll(".color-legend").transition().duration(DURATION).attr("transform",
        #       (d, index, attribute) =>
        #           if show
        #               d3.interpolateString("translate(-100, 0)", "translate(0, 0)")
        #           else
        #               d3.interpolateString("translate(0, 0)", "translate(-100, 0)")
          #
        #   )

      toggleCircleLegend: (show) =>
          @circleLegendOpacity = if show then 1 else 0
          @vis.selectAll(".mature-legend,.legend").style("opacity", @circleLegendOpacity)

      subNodesReady: (subNodeData) =>
          @subNodeData = subNodeData
          for node in @subNodeData
              node.center = @focusCenter
              node.x = @width/2
              node.y = @height/2
              node.px = node.x
              node.py = node.y

          @subNodes = []
          @updateRadiusScale()
          @create_nodes(@subNodeData, @subNodes)
          @render(@subNodes, 'childCircles', true)

          totalAmount = d3.sum(@subNodeData, (d) -> d.value)
          @centerBoundingRadius = @radius_scale_center(totalAmount)

          @subNodeForce.nodes(@subNodes)

          @start()

      reapply_values: () =>
          # Fancy transition to make bubbles appear, ending with the
          # correct radius
          @circles
              .attr("class", (d) -> d.className())
              .transition().duration(DURATION).attr("r", (d) -> d.radius())
          @childCircles
              .attr("class", (d) -> d.className())
              .transition().duration(DURATION).attr("r", (d) -> d.radius())

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
      charge: (d) =>
          if d != @centeredNode
              -Math.pow(d.radius(), 2.0) / 8
          else
              0

      # Sets up force layout to display
      # all nodes in one circle.
      start: () =>
          if @centeredNode?
              @hide_details()
              @vis.selectAll(".main-vis-action-buttons")
                  .transition()
                  .duration(DURATION)
                  .style("opacity", 1)

              centeredElement = @vis.select("#bubble_#{@centeredNode.id}")
                .style("pointer-events", "none")

              centeredElement
                .transition()
                .duration(DURATION)
                .attr("r", (d) -> d.radius())
                .each 'end',  =>
                  if @centeredNode?
                      @actionButtons.moveToFront()
                      @vis.selectAll(".legend").moveToFront()
                      @vis.selectAll(".child-bubble").style("display", "")
                      centeredElement = @vis.select("#bubble_#{@centeredNode.id}")
                      @shadowColor(centeredElement.style("fill"))
                      centeredElement
                        .attr("fill-opacity", "1")
                        .transition()
                        .duration(DURATION)
                        .attr("fill-opacity", "0")
                        .style("filter", "url(#shadow)")
                    else
                      @actionButtons.sendToBack()

          @boundingRadius = @radius_scale(@total_amount/@numParts)
          @force.start()
          @subNodeForce.start()

      calc_averages: () =>
        @averages = {}
        extents = {}
        for d in @nodes
            cat = d.center.category()
            if cat == "focused" then continue
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
            @averages[cat] =
                x: (extent.maxx + extent.minx)/2
                y: (extent.maxy + extent.miny)/2

      centerX: (d) ->
          if @centeredNode? and !d.forceCenter and !d.subNode
              -1000
          else
              d.center.x

      get_offset: (alpha,d) =>
          cat = d.center.category()
          if !@averages[cat]?
              res = { dx: 0, dy: 0 }
          else
              avg = @averages[cat]
              s = ((0.1-alpha)/0.1)
              x = @centerX(d)
              res = {
                dx: s*(avg.x - x),
                dy: s*(avg.y - d.center.y)
              }
          res

      # Moves all circles towards the @center
      # of the visualization
      move_towards_centers: (alpha) =>
          (d) =>
              boundingRadius = if d.subNode then @centerBoundingRadius else @boundingRadius
              boundingRadius = @boundingRadius
              x = @centerX(d)
              d.x = d.x + (x - d.x) * (@damper + 0.02) * alpha
              targetY =  d.center.y - d3.min([1,d.part]) * boundingRadius
              d.y = d3.max([0, d.y + (d.center.y - d.y) * (@damper + 0.02) * alpha + (targetY - d.y) * (@damper) * alpha * alpha * alpha * 500])

      show_details: (data, i, element) =>

          d3.select(element)
            .style('stroke-width',4)
          $(".bubble-chart-tip").toggleClass('active',true)
          @tooltip.show(data)
          @activeTooltip = {data: data, element: element}

      hide_details: () =>
          if @activeTooltip?
              d3.select(@activeTooltip.element)
                .style('stroke-width',1)
              @tooltip.hide(@activeTooltip.data)
              $(".bubble-chart-tip").toggleClass('active',false)

    BubbleChart
)
