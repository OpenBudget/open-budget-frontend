define(['jquery', 'backbone', 'models', 'combined_history'], ($, Backbone, models, combined_history) ->
    class OverviewWidget extends Backbone.View

            VALUE_MARGIN = 0.1
            CHART_MARGIN_TOP = 15 #px
            MARGIN = 10 #px

            HANDLE_WIDTH = 7
            HANDLE_HEIGHT = 18

            initialize: ->
                    @rendered = false
                    @selectionBarRendered = false
                    @pageModel = window.pageModel
                    @pageModel.on "change:selection", => @renderSelectionBar()
                    @pageModel.on "resized", =>
                      @render()
                      @renderSelectionBar()

                    @svg = d3.select(@el).append('svg')
                            .attr('width','100%')
                            .attr('height','100%')
                    @svg.append('defs').html('<pattern id="upperApprovedRect" patternUnits="userSpaceOnUse" width="4" height="4"><path d="M-1,1 l2,-2 M0,4 l4,-4 M3,5 l2,-2" stroke-width="1" /></pattern>')
                    @svg.append('defs').html('<pattern id="lowerApprovedRect" patternUnits="userSpaceOnUse" width="4" height="4"><path d="M-1,1 l2,-2 M0,4 l4,-4 M3,5 l2,-2" stroke-width="1" /></pattern>')

                    @approvedBarBgs = @svg.append('g').attr('class','approvedBarBgs')
                    @approvedBars = @svg.append('g').attr('class','approvedBar')
                    @changeBars = @svg.append('g').attr('class','changeBar')
                    @yearNumberTexts = @svg.append('g').attr('class','yearNumberText')
                    @selectionBar = @svg.append('g').attr('class','selectionBar')

                    that = @
                    @drag = d3.behavior.drag()
                            .on("drag", (d) ->
                                    selection_orig = that.pageModel.get('selection')
                                    selection = selection_orig[0..1]
                                    selection_src = parseInt(d3.select(@).attr('data-selection'))
                                    x = d3.event.x
                                    newX = that.baseTimeScale.invert(x)
                                    if selection_src == 0
                                            if newX < selection[1]
                                                    selection[0] = newX
                                            else
                                                    selection[0] = selection[1]-1
                                    else if selection_src == 1
                                            if newX > selection[0]
                                                    selection[1] = newX
                                            else
                                                    selection[1] = selection[0] + 1
                                    else if selection_src == 2
                                            dx = d3.event.dx
                                            dx = that.baseTimeScale.invert(dx) - that.baseTimeScale.invert(0)
                                            selection[0] += dx
                                            selection[1] += dx
                                    else
                                        return
                                    if selection[0] >= that.model.minTime && selection[1] <= that.model.maxTime
                                        that.pageModel.set('selection', selection)
                    )

                    @render()

            renderSelectionBar: ->

                    selection = @pageModel.get('selection')
                    selectionLines = @selectionBar.selectAll('.selectionLine').data( selection )
                    if (@selectionBarRendered == false)
                        selectionLines.enter()
                            .append('line')
                            .attr('class','selectionLine')
                    else
                        selectionLines.select(".selectionLine")

                    selectionLines
                        .attr('y1',0)
                        .attr('y2',@maxHeight+2*MARGIN)
                        .attr('x1',(d) => @timeScale(d) )
                        .attr('x2',(d) => @timeScale(d) )

                    selectionHandles = @selectionBar.selectAll('.selectionHandle').data( selection )
                    if (@selectionBarRendered == false)
                        selectionHandles.enter()
                                .append('rect')
                                .attr('class','selectionHandle')
                    else
                        selectionHandles.select(".selectionHandle")

                    selectionHandles
                        .attr('data-selection', (d,i) -> i)
                        .attr('height', HANDLE_HEIGHT)
                        .attr('width', HANDLE_WIDTH )
                        .attr('y',(@maxHeight-HANDLE_HEIGHT)/2 + MARGIN )
                        .call(@drag)

                    selectionHandles
                        .attr('x',(d,i) => @timeScale(d) + if i == 0 then -HANDLE_WIDTH else 0 )

                    selectionShade = @selectionBar.selectAll('.selectionShade').data( [selection] )
                    if (@selectionBarRendered == false)
                        selectionShade
                            .enter()
                            .append('rect')
                    else
                        selectionShade.select("rect")

                    selectionShade
                        .attr('class','selectionShade')
                        .attr('data-selection', '2')
                        .attr('y',MARGIN)
                        .attr('height',@maxHeight)
                        .call(@drag)
                    selectionShade
                        .attr('x',(d) => @timeScale(d[0]) )
                        .attr('width',(d) => @timeScale(d[1]) - @timeScale(d[0]) )

                    @selectionBarRendered = true

            render: () ->
                    @maxWidth = $(@el).width()
                    @maxHeight = $(@el).height() - 2*MARGIN

                    valueRange = @model.maxValue - @model.minValue
                    valueMargin = VALUE_MARGIN*valueRange
                    @minValue = _.min([ @model.minValue - valueMargin, 0 ])
                    @maxValue = @model.maxValue + _.max([ valueMargin, ((valueRange * CHART_MARGIN_TOP) / (@maxHeight - CHART_MARGIN_TOP))])
                    @pixelPerfecter = (t) =>
                            Math.floor(t) + 0.5

                    @baseTimeScale = d3.scale.linear()
                            .domain([@model.minTime, @model.maxTime])
                            .range([10, @maxWidth-10])
                    @yearSeperatingScale = (t) =>
                            year = new Date(t).getFullYear()
                            base = new Date(year,0).valueOf()
                            #console.log t, year, base
                            base + (t - base) * 0.98
                    @timeScale = (t) =>
                            @pixelPerfecter(@baseTimeScale(@yearSeperatingScale(t)))

                    @baseValueScale = d3.scale.linear()
                            .domain([@minValue, @maxValue])
                            .range([@maxHeight+MARGIN, MARGIN])
                    @valueScale = (t) =>
                            @pixelPerfecter(@baseValueScale(t))

                    if (@rendered == false)
                        # Calculate initial selection
                        if 4 < pageModel.get('budgetCode').length < 10
                            selectionStart = @model.maxTime - 3500 * 365 * 86400
                        else
                            selectionStart = @model.minTime
                        if selectionStart < @model.minTime
                            selectionStart = @model.minTime
                        selectionEnd = @model.maxTime
                        @pageModel.set('selection', [ selectionStart, selectionEnd ] )
                    else
                        @renderSelectionBar()

                    approvedBarBgs = @approvedBarBgs.selectAll('.approvedBarBg')
                        .data(_.filter(@model.models, (p) -> p.get('kind') == 'yearstart'))

                    if (@rendered == false)
                        approvedBarBgs
                            .enter()
                            .append("g")
                            .attr("class", "approvedBarBg widgetElement")
                                .append("rect")
                                .attr("class", "lower")

                    approvedBarBgs.select(".lower")
                      .attr("x", (d) => @timeScale( d.get('timestamp') ) )
                      .attr("y", (d) => @valueScale( @maxValue) )
                      .attr("width", (d) => @timeScale(364*86400*1000 + d.get('timestamp')) - @timeScale( d.get('timestamp')))
                      .attr("height", @valueScale(0) - @valueScale(@maxValue))

                    # Lines of each year's budget
                    approvedBars = @approvedBars.selectAll('.approvedBar')
                        .data(_.filter(@model.models, (p) -> p.get('kind') == 'approved'))

                    if (@rendered == false)
                        # Create elements on initial render
                        approvedBars
                            .enter()
                            .append("g")
                            .attr("class", "approvedBar widgetElement")
                            .append("line")
                    else
                        # Select elements on any subsequent render
                        approvedBars
                            .select("line")

                    approvedBars
                        .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("y1", (d) => @valueScale( d.get('value') ) )
                        .attr("x2", (d) => @timeScale( d.get('timestamp') + d.get('width') ) )
                        .attr("y2", (d) => @valueScale( d.get('value') ) )

                    # Bars of individual changes
                    changeBars = @changeBars.selectAll('.changeBar')
                        .data(_.filter(@model.models, (p) -> p.get('kind') == 'change'))

                    if (@rendered == false)
                        # Create elements on initial render
                        changeBars
                            .enter()
                            .append("line")
                            .attr("class", (d) => cls = changeClass( d.get('original_baseline'), d.get('value') ); subkind = d.get('subkind') ; "changeBar widgetElement #{cls} #{subkind}" )
                    else
                        # Select elements on any subsequent render
                        changeBars.select("line")

                    changeBars
                        .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("x2", (d) => @timeScale( d.get('timestamp') + d.get('width') ) )
                        .attr("y1", (d) => @valueScale( d.get('value') ) )
                        .attr("y2", (d) => @valueScale( d.get('value') ) )

                    # Year numbers
                    yearNumberTexts = @yearNumberTexts.selectAll('.yearNumberText')
                        .data(_.filter(@model.models, (p) -> p.get('kind') == 'yearstart'))

                    if (@rendered == false)
                        # Create elements on initial render
                        yearNumberTexts
                            .enter()
                            .append("text")
                    else
                        # Select elements on any subsequent render
                        yearNumberTexts.select("text")

                    yearNumberTexts
                        .attr("class", "yearNumberText widgetElement")
                        .attr("x", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("y", (d) => @valueScale( @maxValue ) )
                        .attr("dx", 3 )
                        .attr("dy", 9 )
                        .style("font-size", 8)
                        .style("text-anchor", "end")
                        .text((d) => new Date(d.get('timestamp')).getFullYear() )

                    @rendered = true


    if models.pageModel.get('budgetCode')?
        console.log "history_widget"
        models.pageModel.on 'ready-budget-history', ->
            overviewWidget = new OverviewWidget({el: $("#overview-widget"),model: window.combinedHistory});
            window.overviewWidget = overviewWidget

    return OverviewWidget
)
