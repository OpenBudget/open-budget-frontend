class IndepthWidget extends Backbone.View

        TOP_PART_SIZE = 200 #p
        TICKS = 10

        YEAR_LINE_HANG_LENGTH = 46 # px
        CHANGE_LINE_HANG_LENGTH = 18 # px

        initialize: ->
                @pageModel = window.pageModel
                @pageModel.on 'change:selection', => @render()

                @svg = d3.select(@el).append('svg')
                        .attr('width','100%')
                        .attr('height','100%')
                @svg.append('defs').html('<pattern id="backgroundPattern" patternUnits="userSpaceOnUse" width="4" height="4"><path d="M-1,1 l2,-2 M0,4 l4,-4 M3,5 l2,-2" stroke-width="1" /></pattern>')

                @chart = @svg.append('g').attr('class','chart')
                @bars = @svg.append('g').attr('class','bar')

        render: ->

                @maxWidth = $(@el).width()
                @maxHeight = $(@el).height()

                @setValueRange()

                @minTime = @pageModel.get('selection')[0]
                @maxTime = @pageModel.get('selection')[1]

                @baseTimeScale = d3.scale.linear()
                        .domain([@minTime, @maxTime])
                        .range([0, @maxWidth])
                @yearSeperatingScale = (t) =>
                        year = new Date(t).getFullYear()
                        base = new Date(year,0).valueOf()
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

                @chart.selectAll('.background').data([1])
                        .enter()
                                .append('rect')
                                .attr("class", "background")
                                .style("fill", "url(#backgroundPattern)")
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
                newGraphParts
                        .append('text')
                                .attr('class', 'approvedLabel')
                                .style("font-size", 12)
                                .attr("dx",3)
                                .text((d) => d.get('date').getFullYear())
                                .style("text-anchor", "end")
                                .datum( (d) => d)

                @chart.selectAll('.approvedLine').data(approvedModels)
                        .attr("class", (d) => dby = d.get('diff-yearly'); if dby < 0 then "approvedLine reduce" else if dby > 0 then "approvedLine increase" else "approvedLine" )
                        .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("x2", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("y1", (d) => @valueScale( d.get('value') ) )
                        .attr("y2", (d) => @valueScale( @minValue ) + YEAR_LINE_HANG_LENGTH )
                @chart.selectAll('.approvedBar').data(approvedModels)
                        .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("x2", (d) => @timeScale( d.get('timestamp') + d.get('width') ) )
                        .attr("y1", (d) => @valueScale( d.get('value') ) )
                        .attr("y2", (d) => @valueScale( d.get('value') ) )
                @chart.selectAll('.approvedLabel').data(approvedModels)
                        .attr("x", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("y", (d) => @valueScale( @minValue ) + YEAR_LINE_HANG_LENGTH )

                changeModels = _.filter(@model.models, (x)->x.get('kind')=='change')
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

                @chart.selectAll('.changeBar').data(changeModels)
                        .attr("class", (d) => dbl = d.get('diff-baseline'); subkind = d.get('subkind') ; if dbl > 0 then "changeBar increase #{subkind}" else if dbl < 0 then "changeBar reduce #{subkind}" else "changeBar  #{subkind}")
                        .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("x2", (d) => @timeScale( d.get('timestamp') + d.get('width') ) )
                        .attr("y1", (d) => @valueScale( d.get('value') ) )
                        .attr("y2", (d) => @valueScale( d.get('value') ) )
                @chart.selectAll('.changeLine').data(changeModels)
                        .attr("class", (d) => if d.get('diff-value') > 0 then "changeLine increase" else "changeLine reduce")
                        .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("x2", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("y1", (d) => @valueScale( d.get('value') + _.max([0, -d.get('diff-value')]) ) )
                        .attr("y2", (d) => if d.get('source') == "dummy" then @valueScale( d.get('value') + _.max([0, -d.get('diff-value')]) ) else @valueScale(@minValue) + CHANGE_LINE_HANG_LENGTH )

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
                newGraphParts
                        .append('circle')
                                .attr('class', 'usedMarker')
                                .datum( (d) => d)

                @chart.selectAll('.usedBar').data(usedModels)
                        .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                        .attr("x2", (d) => @timeScale( d.get('timestamp') + d.get('width') ) )
                        .attr("y1", (d) => @valueScale( d.get('value') ) )
                        .attr("y2", (d) => @valueScale( d.get('value') ) )
                @chart.selectAll('.usedLine').data(usedModels)
                        .attr("x1", (d) => @timeScale( d.get('timestamp') + d.get('width') ) )
                        .attr("x2", (d) => @timeScale( d.get('timestamp') + d.get('width') ) )
                        .attr("y1", (d) => @valueScale( d.get('value') ) )
                        .attr("y2", (d) => @valueScale( @minValue ) + YEAR_LINE_HANG_LENGTH  )
                @chart.selectAll('.usedLabel').data(usedModels)
                        .attr("x", (d) => @timeScale( d.get('timestamp') + d.get('width') ) )
                        .attr("y", (d) => @valueScale( @minValue ) + YEAR_LINE_HANG_LENGTH )



        formatNumber: (n) ->
                rx=  /(\d+)(\d{3})/
                String(n*1000).replace(/^\d+/, (w) ->
                        while rx.test(w)
                            w = w.replace rx, '$1,$2'
                        w)

        setValueRange: () ->
                @valueRange = @model.maxValue - @model.minValue
                scale = 1
                valueRange = @valueRange
                RATIO = (TICKS-1) / TICKS
                while valueRange > 1*RATIO
                        scale *= 10
                        valueRange /= 10
                if valueRange < 0.25*RATIO
                        @tickValue = 0.025*scale
                        @labelValue = 0.1*scale
                if valueRange < 0.5*RATIO
                        @tickValue = 0.05*scale
                        @labelValue = 0.2*scale
                if valueRange <=1*RATIO
                        @tickValue = 0.1*scale
                        @labelValue = 0.2*scale
                @minValue = Math.floor(@model.minValue / @tickValue) * @tickValue
                @maxValue = @minValue + TICKS * @tickValue



$( ->
        console.log "indepth_widget"
        window.indepthWidget = new IndepthWidget({el: $("#indepth-widget"),model: window.widgetData});
)
