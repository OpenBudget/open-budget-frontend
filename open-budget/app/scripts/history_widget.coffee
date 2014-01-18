
class OverviewWidget extends Backbone.View

        VALUE_MARGIN = 0.1
        CHART_MARGIN_TOP = 15 #px
        MARGIN = 10 #px

        HANDLE_WIDTH = 7
        HANDLE_HEIGHT = 18

        initialize: ->
                @model.on 'reset', => @render()
                @svg = d3.select(@el).append('svg')
                        .attr('width','100%')
                        .attr('height','100%')
                @svg.append('defs').html('<pattern id="upperApprovedRect" patternUnits="userSpaceOnUse" width="4" height="4"><path d="M-1,1 l2,-2 M0,4 l4,-4 M3,5 l2,-2" stroke-width="1" /></pattern>')
                @svg.append('defs').html('<pattern id="lowerApprovedRect" patternUnits="userSpaceOnUse" width="4" height="4"><path d="M-1,1 l2,-2 M0,4 l4,-4 M3,5 l2,-2" stroke-width="1" /></pattern>')
                @changeBars = @svg.append('g').attr('class','changeBar')
                @approvedBars = @svg.append('g').attr('class','approvedBar')
                @yearNumberTexts = @svg.append('g').attr('class','yearNumberText')
                @selectionBar = @svg.append('g').attr('class','selectionBar')

        renderSelectionBar: ->
                selectionLines = @selectionBar.selectAll('.selectionLine').data( @selection )
                selectionLines.enter()
                        .append('line')
                        .attr('class','selectionLine')
                selectionLines.attr('y1',0)
                        .attr('y2',@maxHeight+2*MARGIN)
                        .attr('x1',(d) => @timeScale(d) )
                        .attr('x2',(d) => @timeScale(d) )

                that = @
                drag = d3.behavior.drag()
                        .on("drag", (d) ->
                                selection_src = parseInt(d3.select(@).attr('data-selection'))
                                x = d3.event.x
                                newX = that.baseTimeScale.invert(x)
                                if selection_src == 0
                                        if newX < that.selection[1]
                                                that.selection[0] = newX
                                if selection_src == 1
                                        if newX > that.selection[0]
                                                that.selection[1] = newX
                                if selection_src == 2
                                        dx = d3.event.dx
                                        dx = that.baseTimeScale.invert(dx) - that.baseTimeScale.invert(0)
                                        that.selection[0] += dx
                                        that.selection[1] += dx
                                that.renderSelectionBar()
                        )
                        
                selectionHandles = @selectionBar.selectAll('.selectionHandle').data( @selection )
                selectionHandles.enter()
                        .append('rect')
                        .attr('class','selectionHandle')
                        .attr('data-selection', (d,i) -> i)
                        .attr('height', HANDLE_HEIGHT)
                        .attr('width', HANDLE_WIDTH )
                        .attr('y',(@maxHeight-HANDLE_HEIGHT)/2 + MARGIN )
                        .call(drag)
                selectionHandles
                        .attr('x',(d,i) => @timeScale(d) + if i == 0 then -HANDLE_WIDTH else 0 )
                        
                selectionShade = @selectionBar.selectAll('.selectionShade').data( [@selection] )
                selectionShade.enter()
                        .append('rect')
                        .attr('class','selectionShade')
                        .attr('data-selection', '2')
                        .attr('y',MARGIN)
                        .attr('height',@maxHeight)
                        .call(drag)
                selectionShade
                        .attr('x',(d) => @timeScale(d[0]) )
                        .attr('width',(d) => @timeScale(d[1]) - @timeScale(d[0]) )
                        

        render: ->

                @maxWidth = $(@el).width()
                @maxHeight = $(@el).height() - 2*MARGIN

                valueRange = @model.maxValue - @model.minValue
                valueMargin = VALUE_MARGIN*valueRange
                @minValue = _.min([ @model.minValue - valueMargin, 0 ])
                @maxValue = @model.maxValue + _.max([ valueMargin, ((valueRange * CHART_MARGIN_TOP) / (@maxHeight - CHART_MARGIN_TOP))])
                selectionStart = @model.minTime * 0.5 + @model.maxTime * 0.5
                selectionEnd = @model.minTime * 0.25 + @model.maxTime * 0.75
                @selection = [ selectionStart, selectionEnd ]

                @baseTimeScale = d3.scale.linear()
                        .domain([@model.minTime, @model.maxTime])
                        .range([0, @maxWidth])
                @timeScale = (t) =>
                        year = new Date(t).getFullYear()
                        base = new Date(year,0).valueOf()                       
                        #console.log t, year, base
                        @baseTimeScale( base + (t - base) * 0.98 )
                @valueScale = d3.scale.linear()
                        .domain([@minValue, @maxValue])
                        .range([@maxHeight+MARGIN, MARGIN])

                @renderSelectionBar()

                console.log 'OverviewWidget',@maxWidth,@maxHeight

                # Bars of individual changes
                changeBars = @changeBars.selectAll('.changeBar')
                    .data(_.filter(@model.models, (p) -> p.get('kind') == 'change'))
                    .enter()
                        .append("rect")
                        .attr("class", "changeBar widgetElement")
                        .attr("data-z", 0)
                        .attr("x", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("y", (d) => @valueScale( d.get('value') ) )
                        .attr("width", (d) => Math.ceil( @timeScale( d.get('width') ) - @timeScale(0) ) )
                        .attr("height", (d) => @valueScale(0) - @valueScale(d.get('value')) )
                        .style("stroke", "none")

                # Lines of each year's budget
                approvedBars = @approvedBars.selectAll('.approvedBar')
                    .data(_.filter(@model.models, (p) -> p.get('kind') == 'approved'))
                    .enter()
                        .append("g")
                        .attr("class", "approvedBar widgetElement")
                approvedBars
                        .append("rect")
                        .attr("class", "lower")
                        .attr("x", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("y", (d) => @valueScale( d.get('value') ) )
                        .attr("width", (d) => @timeScale( d.get('timestamp') + d.get('width') ) - @timeScale( d.get('timestamp') ) )
                        .attr("height", (d) => @valueScale(0) - @valueScale( d.get('value') ) )
                        .style("fill", "url(#lowerApprovedRect)")
                        .style("stroke", null)
                approvedBars
                        .append("rect")
                        .attr("class", "upper")
                        .attr("x", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("y", (d) => @valueScale( @maxValue ) )
                        .attr("width", (d) => @timeScale( d.get('timestamp') + d.get('width') ) - @timeScale( d.get('timestamp') ) )
                        .attr("height", (d) => @valueScale( d.get('value') ) - @valueScale( @maxValue ) )
                        .style("fill", "url(#upperApprovedRect)")
                        .style("stroke", null)
                approvedBars
                        .append("line")
                        .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("y1", (d) => @valueScale( d.get('value') ) )
                        .attr("x2", (d) => @timeScale( d.get('timestamp') + d.get('width') ) )
                        .attr("y2", (d) => @valueScale( d.get('value') ) )


                # Year numbers
                yearNumberTexts = @yearNumberTexts.selectAll('.yearNumberText')
                    .data(_.filter(@model.models, (p) -> p.get('kind') == 'approved'))
                    .enter()
                        .append("text")
                        .attr("class", "yearNumberText widgetElement")
                        .attr("data-z", 2)
                        .attr("x", (d) => @timeScale( d.get('timestamp') + d.get('width') ) )
                        .attr("y", (d) => @valueScale( @maxValue ) )
                        .attr("dx", -3 )
                        .attr("dy", 9 )
                        .style("font-size", 8)
                        .style("text-anchor", "start")
                        .text((d) => new Date(d.get('timestamp')).getFullYear() )
                

        
$( ->
        console.log "history_widget"
        window.overviewWidget = new OverviewWidget({el: $("#overview-widget"),model: window.widgetData});
)
