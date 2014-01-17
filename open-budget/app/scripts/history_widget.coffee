
class OverviewWidget extends Backbone.View

        VALUE_MARGIN = 0.1
        MARGIN_TOP = 15 #px

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

        render: ->

                @maxWidth = $(@el).width()
                @maxHeight = $(@el).height()

                valueRange = @model.maxValue - @model.minValue
                valueMargin = VALUE_MARGIN*valueRange
                @minValue = _.min([ @model.minValue - valueMargin, 0 ])
                @maxValue = @model.maxValue + _.max([ valueMargin, ((valueRange * MARGIN_TOP) / (@maxHeight - MARGIN_TOP))])

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
                        .range([@maxHeight, 0])

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
                        .attr("y", (d) => 0 )
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
                        .attr("y", 10 )
                        .style("font-size", 8)
                        .style("text-anchor", "start")
                        .text((d) => new Date(d.get('timestamp')).getFullYear() )
                

        
$( ->
        console.log "history_widget"
        window.overviewWidget = new OverviewWidget({el: $("#overview-widget"),model: window.widgetData});
)
