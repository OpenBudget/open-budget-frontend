class IndepthWidget extends Backbone.View

        TOP_PART_SIZE = 200 #p
        TICKS = 10
        TOOLTIP_SIZE = 50

        YEAR_LINE_HANG_LENGTH = 46 # px
        CHANGE_LINE_HANG_LENGTH = 18 # px

        initialize: ->
                @pageModel = window.pageModel
                @pageModel.on 'change:selection', => @render()

                @$el.html('')
                @svg = d3.select(@el).append('svg')
                        .attr('width','100%')
                        .attr('height','100%')

                @chart = @svg.append('g').attr('class','chart')
                @bars = @svg.append('g').attr('class','bar')

                that = @
                @drag = d3.behavior.drag()
                        .on("drag", (d) ->
                                selection_orig = that.pageModel.get('selection')
                                selection = selection_orig[0..1]
                                x = d3.event.x
                                newX = that.baseTimeScale.invert(x)
                                dx = d3.event.dx
                                dx = that.baseTimeScale.invert(dx) - that.baseTimeScale.invert(0)

                                if (selection[0]-dx) > that.model.minTime && (selection[1]-dx) < that.model.maxTime
                                    selection[0] -= dx
                                    selection[1] -= dx
                                    that.pageModel.set('selection', selection)
                )
                @change_tip = d3.tip()
                               .attr('class', 'd3-tip')
                               #.offset((d) => [-(@timeScale( d.get('width')/2 ) - @timeScale(0)), @valueScale(0) - @valueScale( d.get('value') )])
                               .direction((d) => if d3.event.pageX < @maxWidth*0.15 then "ne" else (if d3.event.pageX> @maxWidth*0.85 then "nw" else "n"))
                               .offset((d) => [-TOOLTIP_SIZE+45+@valueScale( d.get('value') ) ,0])
                               .html((d) -> if d.get('source') != 'dummy' then JST.widget_change_tooltip(d) else "")
                @chart.call( @change_tip )
                that = this
                @showTip = (d,i) ->
                        that.change_tip.show(d)
                        d3.select(this).style('opacity',0.1)
                        selector = '.tipFocus'
                        s = that.chart.selectAll(selector)[0][i]  #.data([d])
                        d3.select(s).style('display','block')
                        true
                @hideTip = (d,i) ->
                        d3.select(this).style('opacity',0)
                        that.change_tip.hide(d)
                        # that.participant_tip.hide(d)
                        selector = '.tipFocus'
                        s = that.chart.selectAll(selector)[0][i]  #.data([d])
                        d3.select(s).style('display','none')
                        true
                @showGuideline = ->
                        mouse = d3.mouse(this)
                        that.chart.selectAll('.guideline')
                            .attr('x1',mouse[0])
                            .attr('x2',mouse[0])
                            .style('visibility','visible')
                        date = that.baseTimeScale.invert(mouse[0])
                        date = new Date(date)
                        ofs = $(that.svg[0]).offset()
                        d3.select("#indepth-guideline-date")
                            .html(date.getDate()+"/"+(date.getMonth()+1)+"/"+date.getFullYear())
                            .style('display','block')
                            .style('left', d3.event.pageX+"px")
                            .style('top',ofs.top+that.valueScale(0)+"px")
                        true
                @hideGuideline = ->
                        that.chart.selectAll('.guideline')
                            .style('visibility','hidden')
                        d3.select("#indepth-guideline-date")
                            .html("")
                            .style('display','none')
                        true

                @participants = []
                @titles = []
                @titleToIndex = {}

        render__chart_bg: ->

                @chart.selectAll('.background').data([1])
                        .enter()
                                .append('rect')
                                .attr("class", "background")
                                .style("stroke", null)

                @chart.selectAll('.background').data([1])
                        .attr("x", (d) => @timeScale( @minTime ) )
                        .attr("y", (d) => @valueScale( @maxValue ) )
                        .attr("width", (d) => @timeScale( @maxTime ) - @timeScale( @minTime ) )
                        .attr("height", (d) => @valueScale( @minValue ) - @valueScale( @maxValue ) )

                allLabelIndexes = _.map([0..9], (x) =>
                        index: x
                        major: (@minValue + x*@tickValue) % @labelValue < 1
                        )

                @chart.selectAll(".graduationLine")
                        .data(allLabelIndexes)
                        .enter()
                                .append('line')
                                .attr('class', (d) -> 'graduationLine ' + (if d.major then "major" else "minor"))
                @chart.selectAll(".graduationLine")
                        .data(allLabelIndexes)
                        .attr('x1', (d) => @timeScale( @minTime ))
                        .attr('x2', (d) => @timeScale( @maxTime ))
                        .attr('y1', (d) => @valueScale( @minValue + d.index*@tickValue ))
                        .attr('y2', (d) => @valueScale( @minValue + d.index*@tickValue ))

                graduationLabels = @chart.selectAll('.graduationLabel')
                        .data(_.filter(allLabelIndexes, (x)->x.major))
                graduationLabels.enter()
                        .append('text')
                        .attr("class", "graduationLabel")
                        .attr("x", (d) => @timeScale( @minTime ) )
                        .attr("y", (d) => @valueScale( @minValue + d.index*@tickValue ) )
                        .attr("dx", 5 )
                        .attr("dy", -1 )
                        .style("font-size", 8)
                        .style("text-anchor", "end")
                        .text((d) => @formatNumber( @minValue + d.index*@tickValue ) )

                # Guideline
                @chart.selectAll('.guideline').data([1])
                        .enter()
                            .append('line')
                            .attr('class','guideline')
                            .attr('y1',0)
                            .attr('y2',@valueScale(0)+CHANGE_LINE_HANG_LENGTH)
                            .style('stroke','#000')

                d3.select('body').selectAll('#indepth-guideline-date').data([1])
                        .enter()
                            .append('div')
                            .attr('id','indepth-guideline-date')

                @svg.on('mousemove',@showGuideline)
                @svg.on('mouseout',@hideGuideline)

        render__year_starts: ->
                yearstartModels = _.filter(@model.models, (x)->x.get('kind')=='yearstart')
                newGraphParts = @chart.selectAll('.graphPartYearStart').data(yearstartModels)
                        .enter().append("g")
                        .attr('class','graphPartYearStart')
                newGraphParts
                        .append('line')
                                .attr('class', 'yearstartLine')
                                .datum( (d) => d)
                newGraphParts
                        .append('text')
                                .attr('class', 'yearstartLabel')
                                .style("font-size", 12)
                                .attr("dx",3)
                                .text((d) => d.get('date').getFullYear())
                                .style("text-anchor", "end")
                                .datum( (d) => d)

                @chart.selectAll('.yearstartLine').data(yearstartModels)
                        .attr("class", "yearstartLine" )
                        .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("x2", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("y1", (d) => @valueScale( d.get('value') ) )
                        .attr("y2", (d) => @valueScale( @minValue ) + YEAR_LINE_HANG_LENGTH )
                @chart.selectAll('.yearstartLabel').data(yearstartModels)
                        .attr("x", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("y", (d) => @valueScale( @minValue ) + YEAR_LINE_HANG_LENGTH )

        render__approved_budgets: ->
                approvedModels = _.filter(@model.models, (x)->x.get('kind')=='approved')
                newGraphParts = @chart.selectAll('.graphPartApproved').data(approvedModels)
                        .enter().append("g")
                        .attr('class','graphPartApproved')
                newGraphParts
                        .append('line')
                                .attr('class', 'approvedLine')
                                .datum( (d) => d)
                newGraphParts
                        .append('line')
                                .attr('class', 'approvedBar')
                                .datum( (d) => d)
                newTips = d3.select('#approvedTooltips').selectAll('.approvedTip').data(approvedModels)
                            .enter().append("div")
                            .attr("class","approvedTip participantTooltip")
                            .html((d) -> JST.widget_participant_tooltip({participants: d.get('participants')}))

                d3.select('#approvedTooltips').selectAll('.approvedTip').data(approvedModels)
                            .style("left", (d) => (@timeScale(d.get('timestamp')))+"px" )
                            .style("top", "0px" )

                @chart.selectAll('.approvedBar').data(approvedModels)
                        .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("x2", (d) => @timeScale( d.get('timestamp') + d.get('width') ) )
                        .attr("y1", (d) => @valueScale( d.get('value') ) )
                        .attr("y2", (d) => @valueScale( d.get('value') ) )

        render__revised_budgets: ->
                revisedModels = _.filter(@model.models, (x)->x.get('kind')=='revised' and !x.get('disabled'))
                newGraphParts = @chart.selectAll('.graphPartRevised').data(revisedModels)
                        .enter().append("g")
                        .attr('class','graphPartRevised')
                newGraphParts
                        .append('line')
                                .attr('class', 'revisedBar')
                                .datum( (d) => d)
                @chart.selectAll('.revisedBar').data(revisedModels)
                        .attr("class", (d) => dby = d.get('diff_baseline'); if dby < 0 then "revisedBar reduce" else if dby > 0 then "revisedBar increase" else "revisedBAr" )
                        .attr("x1", (d) => @timeScale( d.get('timestamp') - d.get('width')) )
                        .attr("x2", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("y1", (d) => @valueScale( d.get('original_baseline') ) )
                        .attr("y2", (d) => @valueScale( d.get('value') ) )

        render__change_items: ->
            changeModels = _.filter(@model.models, (x)->x.get('kind')=='change')
            lastChanges = _.filter(changeModels,(x)->x.get("last"))
            @chart.selectAll(".changeBar-last").data(lastChanges)
                   .enter()
                   .append("rect")
                   .attr("class","changeBar-last")
                   .datum( (d) => d)
            @chart.selectAll(".changeBar-last-line").data(lastChanges)
                   .enter()
                   .append("line")
                   .attr("class","changeBar-last-line")
                   .datum( (d) => d)

            newGraphParts = @chart.selectAll('.graphPartChanged').data(changeModels)
                    .enter().append("g")
                    .attr('class','graphPartChanged')
            newGraphParts
                    .append('line')
                            .attr('class', 'changeBar')
                            .datum( (d) => d)
            newGraphParts
                    .append('line')
                            .attr('class', 'changeLine')
                            .datum( (d) => d)
            newGraphParts
                    .append('line')
                            .attr('class', 'changeLineWaterfall')
                            .datum( (d) => d)

            @chart.selectAll(".changeBar-last").data(lastChanges)
                        .attr("class", (d) => dbl = d.get('diff_baseline'); subkind = d.get('subkind') ; if dbl > 0 then "changeBar-last increase #{subkind}" else if dbl < 0 then "changeBar-last reduce #{subkind}" else "changeBar-last  #{subkind}")
                        .attr("x", (d) => @timeScale( @roundToYearStart( d.get('timestamp') ) ) )
                        .attr("width", (d) => @timeScale( d.get('timestamp') + d.get('width') ) - @timeScale( @roundToYearStart( d.get('timestamp') ) ) )
                        .attr("y", (d) => @valueScale( d.get('value') ) )
                        .attr("height", (d) => @valueScale( @minValue ) - @valueScale( d.get('value') ) )

            @chart.selectAll(".changeBar-last-line").data(lastChanges)
                        .attr("class", (d) => dbl = d.get('diff_baseline'); subkind = d.get('subkind') ; if dbl > 0 then "changeBar-last-line increase #{subkind}" else if dbl < 0 then "changeBar-last-line reduce #{subkind}" else "changeBar-last-line  #{subkind}")
                        .attr("x1", (d) => @timeScale( @roundToYearStart( d.get('timestamp') ) ) )
                        .attr("x2", (d) => @timeScale( d.get('timestamp')))
                        .attr("y1", (d) => @valueScale( d.get('value') ) )
                        .attr("y2", (d) => @valueScale( d.get('value') ) )

            @chart.selectAll('.changeBar').data(changeModels)
                    .attr("class", (d) => dbl = d.get('diff_baseline'); subkind = d.get('subkind') ; if dbl > 0 then "changeBar increase #{subkind}" else if dbl < 0 then "changeBar reduce #{subkind}" else "changeBar  #{subkind}")
                    .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                    .attr("x2", (d) => @timeScale( d.get('timestamp') + d.get('width') ) )
                    .attr("y1", (d) => @valueScale( d.get('value') ) )
                    .attr("y2", (d) => @valueScale( d.get('value') ) )
            @chart.selectAll('.changeLine').data(changeModels)
                    .attr("class", (d) => if d.get('diff_value') > 0 then "changeLine increase" else "changeLine reduce")
                    .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                    .attr("x2", (d) => @timeScale( d.get('timestamp') ) )
                    .attr("y1", (d) => @valueScale( d.get('value') + _.min([0, d.get('diff_value')])*(if d.get('diff_value') > 0 then 1 else 0) ) )
                    .attr("y2", (d) => @valueScale(@minValue) )
                    .attr('stroke-width',5)
                    .style('opacity',0.3)
                    .style('stroke-dasharray','1,2')

            @chart.selectAll('.changeLineWaterfall').data(changeModels)
                    .attr("class", (d) => if d.get('diff_value') > 0 then "changeLineWaterfall increase" else "changeLineWaterfall reduce")
                    .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                    .attr("x2", (d) => @timeScale( d.get('timestamp') ) )
                    .attr("y1", (d) => @valueScale( d.get('value') - d.get('diff_value') )+1*(if d.get('diff_value') > 0 then 1 else -1) )
                    .attr("y2", (d) => @valueScale( d.get('value') )-1*(if d.get('diff_value') > 0 then 1 else -1) )
                    .attr('stroke-width',5)

        render__used_budgets: ->
            usedModels = _.filter(@model.models, (x)->x.get('kind')=='used')
            newGraphParts = @chart.selectAll('.graphPartUsed').data(usedModels)
                    .enter().append("g")
                    .attr('class','graphPartUsed')
            newGraphParts
                    .append('line')
                            .attr('class', 'usedBar')
                            .datum( (d) => d)
            newGraphParts
                    .append('line')
                            .attr('class', 'usedLine')
                            .datum( (d) => d)
            newGraphParts
                    .append('text')
                            .attr('class', 'usedLabel')
                            .style("font-size", 12)
                            .attr("dx",-3)
                            .text((d) => d.get('date').getFullYear())
                            .style("text-anchor", "start")
                            .datum( (d) => d)
            @chart.selectAll('.usedBar').data(usedModels)
                    .attr("x1", (d) => @timeScale( d.get('timestamp') - 9*d.get('width') ) ) # probably an ugly hack
                    .attr("x2", (d) => @timeScale( d.get('timestamp') + d.get('width') ) )
                    .attr("y1", (d) => @valueScale( d.get('value') ) )
                    .attr("y2", (d) => @valueScale( d.get('value') ) )

            @chart.selectAll('.usedLine').data(usedModels)
                    .attr("x1", (d) => @timeScale( d.get('timestamp')) )
                    .attr("x2", (d) => @timeScale( d.get('timestamp')) )
                    .attr("y1", (d) => @valueScale( d.get('value') ) )
                    .attr("y2", (d) => @valueScale( @minValue ) + YEAR_LINE_HANG_LENGTH  )
            @chart.selectAll('.usedLabel').data(usedModels)
                    .attr("x", (d) => @timeScale( d.get('timestamp') ) )
                    .attr("y", (d) => @valueScale( @minValue ) + YEAR_LINE_HANG_LENGTH )

        render__tooltip_hooks: ->
                allModels = _.filter(@model.models, (m)->m.get("kind")=="used" or (m.get("kind")=="change" and m.get("src")=="changeline") or m.get("kind")=="approved")
                newGraphParts = @chart.selectAll('.tooltipHook').data(allModels)
                        .enter().append("g")
                        .attr('class','tooltipHook')
                newGraphParts
                        .append('rect')
                                .style("stroke-width",0)
                                .style("fill","#000")
                                .style("opacity",0)
                                .datum( (d) => d)

                @chart.selectAll('.tooltipHook rect').data(allModels)
                        .attr("x", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("y", 0 )
                        .attr("width", (d) => @timeScale( d.get('timestamp') + d.get('width')) - @timeScale(d.get('timestamp')) )
                        .attr("height", @maxHeight )
                        .on('mouseenter', @showTip)
                        .on('mouseleave', @hideTip)

        render__timeline_titles: ->
                @titleIndexScale = (title) -> TOP_PART_SIZE + YEAR_LINE_HANG_LENGTH + (@titleToIndex[title]+1)*32
                @chart.selectAll('.timelineTitle').data(@titles)
                        .enter()
                        .append("text")
                        .attr('class','timelineTitle')
                        .text((d)->d)
                        .attr('x',@maxWidth-8)
                        .attr('y',(d) => @titleIndexScale(d)+4 )
                        #.style("text-anchor", "end")

        render__timeline_terms: ->
                newGroups = @chart.selectAll('.timelineTerm').data(@participants)
                        .enter()
                        .append('g')
                        .attr('class','timelineTerm')
                newGroups.append('line')
                        .attr('class','termBreadth')
                newGroups.append('line')
                        # .style('stroke','#000')
                        .attr('class','termStart')
                groups = @chart.selectAll('.timelineTerm').data(@participants)
                groups.selectAll('.termBreadth')
                        .attr('x1', (d)=> @timeScale( d.get('start_timestamp') ))
                        .attr('x2', (d)=> @timeScale( d.get('end_timestamp') ))
                        .attr('y1', (d)=> @titleIndexScale(d.get('title')) )
                        .attr('y2', (d)=> @titleIndexScale(d.get('title')) )
                groups.selectAll('.termStart')
                        .attr('x1', (d)=> @timeScale( d.get('end_timestamp') ))
                        .attr('x2', (d)=> @timeScale( d.get('end_timestamp') ))
                        .attr('y1', (d)=> @titleIndexScale(d.get('title')) )
                        .attr('y2', (d)=> @titleIndexScale(d.get('title'))+10 )
                newTumbnails = d3.select('#participantThumbnails')
                                 .selectAll('.participantThumbnail')
                                 .data(@participants)
                                 .enter()
                divs = newTumbnails.append("div")
                                .attr('class','participantThumbnail')
                name = (d) ->
                    ret = d.get('name')
                    if d.get('full_title')?
                        if d.get('full_title') != d.get('title')
                            ret += " - "+d.get('full_title')
                    ret
                divs.append("div")
                        .html(name)
                divs.append("img")
                        .attr('src', (d)=> d.get('photo_url'))
                divs = d3.select('#participantThumbnails')
                         .selectAll('.participantThumbnail')
                         .data(@participants)
                         .style("left", (d)=>@timeScale( d.get('start_timestamp')) + "px")
                         .style("top", (d)=>(@titleIndexScale(d.get('title')) - 240) + "px")

        render: ->
                @svg.call(@drag)
                @maxWidth = $(@el).width()
                @maxHeight = $(@el).height()

                @setValueRange()

                @minTime = @pageModel.get('selection')[0]
                @maxTime = @pageModel.get('selection')[1]

                @baseTimeScale = d3.scale.linear()
                        .domain([@minTime, @maxTime])
                        .range([0, @maxWidth])
                @roundToYearStart = (t) =>
                        year = new Date(t).getFullYear()
                        base = new Date(year,0).valueOf()
                        return base

                @yearSeperatingScale = (t) =>
                        base = @roundToYearStart(t)
                        #console.log t, year, base
                        base + (t - base) * 0.98
                @pixelPerfecter = (t) =>
                        Math.floor(t) + 0.5
                @timeScale = (t) =>
                        @pixelPerfecter(@baseTimeScale(@yearSeperatingScale(t)))
                @baseValueScale = d3.scale.linear()
                        .domain([@minValue, @maxValue])
                        .range([TOP_PART_SIZE, 0])
                @valueScale = (t) =>
                        @pixelPerfecter(@baseValueScale(t))

                @render__chart_bg()
                @render__year_starts()
                @render__approved_budgets()
                @render__revised_budgets()
                @render__change_items()
                @render__used_budgets()
                @render__tooltip_hooks()
                @render__timeline_terms()
                @render__timeline_titles()

        formatNumber: (n) ->
                rx=  /(\d+)(\d{3})/
                String(Math.floor(n*1000)).replace(/^\d+/, (w) ->
                        while rx.test(w)
                            w = w.replace rx, '$1,$2'
                        w)

        setValueRange: () ->
                @valueRange = @model.maxValue #- @model.minValue
                scale = 1
                valueRange = @valueRange
                RATIO = (1.0*(TOP_PART_SIZE-TOOLTIP_SIZE))/TOP_PART_SIZE
                while valueRange > 1*RATIO
                        scale *= 10
                        valueRange /= 10
                PARTS = 40
                i40 = Math.ceil(valueRange/RATIO*PARTS)
                i40part = i40/PARTS
                i40labelMult = (1 + (i40 % 2)) * 2
                @tickValue = (i40*scale)/(TICKS*PARTS)
                @labelValue = i40labelMult * @tickValue

                @minValue = 0 #  Math.floor(@model.minValue / @tickValue) * @tickValue
                @maxValue = @minValue + TICKS * @tickValue

        setParticipants: ( participants ) ->
            title = null
            @titles = []
            for participant in participants
                participant.setTimestamps()
                if participant.get("title") != title
                    title = participant.get("title")
                    @titleToIndex[title] = @titles.length
                    @titles.push title
            @participants = participants #_.groupBy(participants, (x) -> x.get('title') )


$( ->
        console.log "indepth_widget"
        indepthWidget = new IndepthWidget({el: $("#indepth-widget"),model: window.combinedHistory});
        window.pageModel.on 'ready-budget-history', ->
            indepthWidget.render()
        window.pageModel.on 'ready-participants', ->
            indepthWidget.setParticipants( window.pageModel.participants.models )
            indepthWidget.render()
        window.indepthWidget = indepthWidget
)
