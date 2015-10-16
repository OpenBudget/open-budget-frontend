class IndepthWidget extends Backbone.View

        TOP_PART_SIZE = 200 #p
        TICKS = 10
        TOOLTIP_SIZE = 50

        YEAR_LINE_HANG_LENGTH = 46 # px
        CHANGE_LINE_HANG_LENGTH = 18 # px

        initialize: ->
                @pageModel = window.pageModel
                @pageModel.on 'change:selection', => @render()
                @pageModel.on 'resized', => @render()

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
                @tooltipYOffset = (d) -> -TOOLTIP_SIZE+45+@valueScale( d.get('value') )
                @change_tip = d3.tip()
                               .attr('class', 'd3-tip timeline-tip')
                               .direction((d) => "n") #if d3.event.pageX < @maxWidth*0.15 then "ne" else (if d3.event.pageX> @maxWidth*0.85 then "nw" else "n"))
                               .offset((d) => [@tooltipYOffset(d) ,0])
                               .html((d) -> if d.get('source') != 'dummy' then JST.widget_change_tooltip(d) else "")
                @chart.call( @change_tip )
                that = this
                @showTip = (d,i) ->
                        hook = d3.select(this)
                        that.change_tip.show(d)
                        $(".timeline-tip")
                            .toggleClass('active',true)
                            .css('pointer-events', 'none')
                        that.tipBG.style('opacity',1)
                        for a in ['x','y','width','height']
                            that.tipBG.attr(a, hook.attr(a))
                        that.tipBGleft.attr('width',hook.attr('x'))
                        that.tipBGright.attr('x',parseInt(hook.attr('x'))+parseInt(hook.attr('width')))
                        true
                        # selector = '.tipFocus'
                        # s = that.chart.selectAll(selector)[0][i]  #.data([d])
                        # d3.select(s).style('display','block')

                @hideTip = (d,i) ->
                        #d3.select(this).style('opacity',0)
                        that.change_tip.hide(d)
                        that.tipBG.style('opacity',0.1)
                        $(".timeline-tip").toggleClass('active',false)
                        true
                        # that.participant_tip.hide(d)
                        # selector = '.tipFocus'
                        # s = that.chart.selectAll(selector)[0][i]  #.data([d])
                        # d3.select(s).style('display','none')

                @showGuideline = ->
                        hook = d3.select(this)
                        mouse = d3.mouse(this)
                        that.chart.selectAll('.guideline')
                            .attr('x1',mouse[0])
                            .attr('x2',mouse[0])
                            .style('visibility','visible')
                        date = that.baseTimeScale.invert(mouse[0])
                        date = new Date(date)
                        ofs = $(that.svg[0]).offset()

                        if that.termSegmentTree
                            termList = that.termSegmentTree.queryPoint(that.baseInverseTimeScale(d3.event.pageX + 4))

                            $(".guide-line-photo").remove()
                            $(".participant-hide-photo").removeClass("participant-hide-photo")
                            for term in termList
                                participant = term.data
                                that.participantThumbnails.find("#participant-"+participant.get("unique_id")).addClass("participant-hide-photo")
                                $(JST.participant_photo(participant.attributes))
                                    .css({
                                        left: d3.event.pageX+"px",
                                        top: (that.titleIndexScale(participant.get('title')) +
                                                that.participantThumbnailsOffset.top - 240) + "px"
                                    })
                                    .appendTo('body')

                        d3.select("#indepth-guideline-date")
                            .html(date.getDate()+"/"+(date.getMonth()+1)+"/"+date.getFullYear())
                            .style('display','block')
                            .style('left', d3.event.pageX+"px")
                            .style('top',ofs.top+that.valueScale(0)+"px")
                        if this.tagName=='rect'
                            hook_ofs = mouse[0] - hook.attr('x')
                            hook_width = hook.attr('width')
                            compensation = hook_ofs - hook_width/2
                            sub_compensation = 0
                            tip_width = $('.timeline-tip').width()
                            overflow = mouse[0] - tip_width/2
                            if overflow < 0
                                compensation -= overflow
                                sub_compensation = overflow
                            overflow = mouse[0] + tip_width/2 - that.maxWidth
                            if overflow > 0
                                compensation -= overflow
                                sub_compensation = overflow

                            $('.timeline-tip').css('margin-left',compensation+"px")
                            sheet = document.getElementById('arrow-helper').sheet
                            while sheet.cssRules.length > 0
                                sheet.deleteRule(0)
                            if sub_compensation != 0
                                sheet.insertRule(".timeline-tip .arrow.arrow-bottom:before { margin-left: #{sub_compensation-8}px }")
                                sheet.insertRule(".timeline-tip .arrow.arrow-bottom:after { margin-left: #{sub_compensation-5}px }")
                        d3.event.preventDefault()
                @hideGuideline = ->
                        that.chart.selectAll('.guideline')
                            .style('visibility','hidden')
                        d3.select("#indepth-guideline-date")
                            .html("")
                            .style('display','none')

                        $(".guide-line-photo").remove()
                        $(".participant-hide-photo").removeClass("participant-hide-photo")

                        true

                @scrollToChange = (d, i) ->
                        # TODO someone with eastetic skills should take a look
                        # at the animation types and duration
                        source = d.get("source")
                        uniqueId = source.get("uniqueId")
                        $target = $("#"+uniqueId)
                        # Scroll the window to the selected target
                        $('html, body').animate({
                            scrollTop: $target.offset().top -
                              window.breadcrumbHeaderView.headerHeight()
                        }, 1000, ->
                            # once the scroll is complete,
                            # make the target visually stand out
                            $target.animate({
                                "background-color": "#efefef"
                            }, 200).animate({
                                "background-color": "white"
                            }, 200)
                          )
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

                # Tip Background
                if not @tipBG?
                    @tipBG = @chart.append('rect')
                                    .style('fill','#fff')
                    @tipBGleft = @chart.append('rect')
                                    .style('fill','#ccc')
                                    .style('opacity',0.05)
                                    .attr('y',0)
                                    .attr('height',TOP_PART_SIZE)
                                    .attr('x',0)
                    @tipBGright = @chart.append('rect')
                                    .style('fill','#ccc')
                                    .style('opacity',0.05)
                                    .attr('y',0)
                                    .attr('height',TOP_PART_SIZE)
                                    .attr('x',0)
                                    .attr('width',10000)

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
                        .attr("dx", 10 )
                        .attr("dy", -1 )
                        .style("font-size", 8)
                        .style("text-anchor", "end")
                        .text((d) => @formatNumber( @minValue + d.index*@tickValue ) )

        render__guideline: ->
                # Guideline
                @chart.selectAll('.guideline').data([{w:3,s:'#fff'},{w:1,s:'#000'}])
                        .enter()
                            .append('line')
                            .attr('class','guideline')
                            .attr('y1',0)
                            .attr('y2',@$el.height())
                            .style('stroke', (d)->d.s)
                            .style('stroke-width', (d)->d.w)
                            .style('pointer-events','none')

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
                        .attr("class", (d) => cls = changeClass( d.get('original_baseline'), d.get('value') ); subkind = d.get('subkind') ; "changeBar-last #{cls} #{subkind}" )
                        .attr("x", (d) => @timeScale( @roundToYearStart( d.get('timestamp') ) ) )
                        .attr("width", (d) => @timeScale( d.get('timestamp') + d.get('width') ) - @timeScale( @roundToYearStart( d.get('timestamp') ) ) )
                        .attr("y", (d) => @valueScale( d.get('value') ) )
                        .attr("height", (d) => @valueScale( @minValue ) - @valueScale( d.get('value') ) )

            @chart.selectAll(".changeBar-last-line").data(lastChanges)
                        .attr("class", (d) => cls = changeClass( d.get('original_baseline'), d.get('value') ); subkind = d.get('subkind') ; "changeBar-last-line #{cls} #{subkind}" )
                        .attr("x1", (d) => @timeScale( @roundToYearStart( d.get('timestamp') ) ) )
                        .attr("x2", (d) => @timeScale( d.get('timestamp')))
                        .attr("y1", (d) => @valueScale( d.get('value') ) )
                        .attr("y2", (d) => @valueScale( d.get('value') ) )

            @chart.selectAll('.changeBar').data(changeModels)
                    .attr("class", (d) => cls = changeClass( d.get('original_baseline'), d.get('value') ); subkind = d.get('subkind') ; "changeBar #{cls} #{subkind}" )
                    .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                    .attr("x2", (d) => @timeScale( d.get('timestamp') + d.get('width') ) )
                    .attr("y1", (d) => @valueScale( d.get('value') ) )
                    .attr("y2", (d) => @valueScale( d.get('value') ) )
            @chart.selectAll('.changeLine').data(changeModels)
                    .attr("class", (d) => cls = changeClass( d.get('original_baseline'), d.get('value') ); subkind = d.get('subkind') ; "changeLine #{cls} #{subkind}" )
                    .attr("x1", (d) => @timeScale( d.get('timestamp') ) )
                    .attr("x2", (d) => @timeScale( d.get('timestamp') ) )
                    .attr("y1", (d) => @valueScale( d.get('value') + _.min([0, d.get('diff_value')])*(if d.get('diff_value') > 0 then 1 else 0) ) )
                    .attr("y2", (d) => @valueScale(@minValue) )
                    .attr('stroke-width',5)
                    .style('opacity',0.3)
                    .style('stroke-dasharray','1,2')

            @chart.selectAll('.changeLineWaterfall').data(changeModels)
                    .attr("class", (d) => cls = changeClass( d.get('original_baseline'), d.get('value') ); subkind = d.get('subkind') ; "changeLineWaterfall #{cls} #{subkind}" )
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
                if @show_changes
                    allModels = _.filter(@model.models, (m)->m.get("kind")=="used" or (m.get("kind")=="change" and m.get("src")=="changeline") or m.get("kind")=="approved")
                else
                    allModels = _.filter(@model.models, (m)->m.get("kind")=="used" or m.get("kind")=="approved")
                newGraphParts = @chart.selectAll('.tooltipHook').data(allModels)
                        .enter().append("g")
                        .attr('class','tooltipHook')
                newGraphParts
                        .append('rect')
                                .style("stroke-width",0)
                                .style("fill","#000")
                                .style("opacity",0)
                                .datum( (d) => d)

                get_width = (d) =>
                    ret = d3.max([@timeScale( d.get('timestamp') + d.get('width')) - @timeScale(d.get('timestamp')),10])
                    ret

                get_x = (d) =>
                    z = (@timeScale( d.get('timestamp') + d.get('width')) - @timeScale(d.get('timestamp'))-10)/2
                    ofs = d3.min([0,z])
                    ret = @timeScale( d.get('timestamp') ) + ofs
                    ret

                @chart.selectAll('.tooltipHook rect').data(allModels)
                        .attr("x", get_x )
                        .attr("y", 0 )
                        .attr("width", get_width )
                        .attr("height", "100%" )
                        .on('mouseenter', @showTip)
                        .on('mouseleave', @hideTip)
                        .on('mousemove',@showGuideline)
                        .on("click", @scrollToChange)


        render__timeline_titles: ->
                @titleIndexScale = (title) -> TOP_PART_SIZE + YEAR_LINE_HANG_LENGTH + (@titleToIndex[title]+1)*32
                #@chart.selectAll('.timelineTitle').data(@titles)
                #        .enter()
                #        .append("text")
                #        .attr('class','timelineTitle')
                #        .text((d)->d)
                #        .attr('x',@maxWidth-8)
                #        .attr('y',(d) => @titleIndexScale(d)+3 )
                #        #.style("text-anchor", "end")

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

                if @participants.length > 0
                    # Build an interval tree to quickly search invervals overlapping
                    # a point/segment
                    @centerEpoch = @minTime + (@maxTime - @minTime)/2
                    @termSegmentTree = new segmentTree;
                    for participant, index in @participants
                        startTimestamp = participant.get("start_timestamp")
                        if participant.get("end_date")
                            endTimestamp = participant.get("end_timestamp")
                        else
                            # if there is no end_date we need
                            # to use the current timestam
                            endTimestamp = new Date().getTime()

                        try
                            if startTimestamp? and endTimestamp?
                                @termSegmentTree.pushInterval(startTimestamp, endTimestamp, participant)
                        catch e
                            console.log "segment tree pushInterval error: ",e,participant,@participants
                    try
                        @termSegmentTree.buildTree()
                    catch e
                        console.log "segment tree build error: ",e,@participants


                divs = newTumbnails.append("div")
                                .attr('class','participantThumbnail')
                renderParticipant = (d) ->
                    participant = JST.participant_term(d.attributes)

                divs.html(renderParticipant)
                #divs.append("img")
                #        .attr('src', (d)=> d.get('photo_url'))
                divs = d3.select('#participantThumbnails')
                         .selectAll('.participantThumbnail')
                         .data(@participants)
                         .style("left", (d)=>@timeScale( d.get('start_timestamp')) + "px")
                         .style("width", (d)=>(@timeScale( d.get('end_timestamp')) - @timeScale( d.get('start_timestamp'))) + "px")
                         .style("top", (d)=>(@titleIndexScale(d.get('title')) - 240) + "px")

        render__yearly_lines: ->

                start_models = _.filter(@model.models, (m)->m.get("kind")=="yearstart")
                start_models_starts = start_models.slice(0,-1)
                start_models_ends = start_models.slice(1)
                start_models = _.zip(start_models_starts,start_models_ends)

                simpleApprovedLines = @chart.selectAll('.simpleApprovedLine')
                      .data(start_models)
                news = simpleApprovedLines.enter()
                        .append('g')
                        .attr('class', (d) -> 'simpleApprovedLine '+ changeClass(d[0].get('source').get('net_allocated'), d[1].get('source').get('net_allocated')))
                news.append('line')
                    #.style('stroke','green')
                news.append('circle')
                    .attr('r',1)
                    #.style('stroke','green')
                    #.style('fill','none')

                simpleApprovedLines.selectAll('line')
                      .attr('x1', (d)=> @timeScale(d[0].get('timestamp')))
                      .attr('x2', (d)=> @timeScale(d[1].get('timestamp')))
                      .attr('y1', (d)=> @valueScale(d[0].get('source').get('net_allocated')))
                      .attr('y2', (d)=> @valueScale(d[1].get('source').get('net_allocated')))
                simpleApprovedLines.selectAll('circle')
                      .attr('cx', (d)=> @timeScale(d[1].get('timestamp')))
                      .attr('cy', (d)=> @valueScale(d[1].get('source').get('net_allocated')))

                end_models = _.filter(@model.models, (m)->m.get("kind")=="used")
                end_models_starts = end_models.slice(0,-1)
                end_models_ends = end_models.slice(1)
                end_models = _.zip(end_models_starts,end_models_ends)

                simpleUsedLines = @chart.selectAll('.simpleUsedLine')
                      .data(end_models)
                news = simpleUsedLines.enter()
                            .append('g')
                            .attr('class', (d) -> 'simpleUsedLine '+ changeClass(d[0].get('source').get('net_used'), d[1].get('source').get('net_used')))
                news.append('line')
                      #.style('stroke','red')
                news.append('circle')
                    .attr('r',1)
                    #.style('stroke','red')
                    #.style('fill','none')
                simpleUsedLines.selectAll('line')
                      .attr('x1', (d)=> @timeScale(d[0].get('timestamp')) )
                      .attr('x2', (d)=> @timeScale(d[1].get('timestamp')))
                      .attr('y1', (d)=> @valueScale(d[0].get('source').get('net_used')))
                      .attr('y2', (d)=> @valueScale(d[1].get('source').get('net_used')))
                simpleUsedLines.selectAll('circle')
                      .attr('cx', (d)=> @timeScale(d[1].get('timestamp')))
                      .attr('cy', (d)=> @valueScale(d[1].get('source').get('net_used')))

                simpleRevisedLines = @chart.selectAll('.simpleRevisedLine')
                      .data(end_models)
                news = simpleRevisedLines.enter()
                      .append('g')
                      .attr('class', (d) -> 'simpleRevisedLine '+ changeClass(d[0].get('source').get('net_revised'), d[1].get('source').get('net_revised')))
                news.append('line')
                      #.style('stroke','blue')
                news.append('circle')
                    .attr('r',1)
                    #.style('stroke','blue')
                    #.style('fill','none')
                simpleRevisedLines.selectAll('line')
                      .attr('x1', (d)=> @timeScale(d[0].get('timestamp')))
                      .attr('x2', (d)=> @timeScale(d[1].get('timestamp')))
                      .attr('y1', (d)=> @valueScale(d[0].get('source').get('net_revised')))
                      .attr('y2', (d)=> @valueScale(d[1].get('source').get('net_revised')))
                simpleRevisedLines.selectAll('circle')
                    .attr('cx', (d)=> @timeScale(d[1].get('timestamp')))
                    .attr('cy', (d)=> @valueScale(d[1].get('source').get('net_revised')))

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
                @baseInverseTimeScale = d3.scale.linear()
                        .domain([0, @maxWidth])
                        .range([@minTime, @maxTime])

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

                code = pageModel.get('budgetCode')
                @show_changes = 4 < code.length < 10

                if @show_changes
                    @timeScale = (t) =>
                            @pixelPerfecter(@baseTimeScale(@yearSeperatingScale(t)))
                else
                    @timeScale = (t) =>
                            @pixelPerfecter(@baseTimeScale(t))

                @inverseTimeScale = (t) =>
                            @pixelPerfecter(@baseInverseTimeScale(t))

                @baseValueScale = d3.scale.linear()
                        .domain([@minValue, @maxValue])
                        .range([TOP_PART_SIZE, 0])
                @valueScale = (t) =>
                        @pixelPerfecter(@baseValueScale(t))


                @render__chart_bg()
                @render__year_starts()
                if @show_changes
                    @render__approved_budgets()
                    @render__revised_budgets()
                    @render__change_items()
                    @render__used_budgets()
                else
                    @render__yearly_lines()
                @render__tooltip_hooks()
                @render__timeline_terms()
                @render__timeline_titles()
                @render__guideline()

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
            dupDetector = {}
            dupIndices = []
            for participant, index in participants
                participant.setTimestamps()
                unique_id = participant.get('unique_id')
                if (dupDetector[unique_id])
                    # Push to the begining of the array because we must
                    # remove the indicies in reverse order to presrve location
                    dupIndices.unshift(index)
                    continue

                dupDetector[unique_id] = participant
                if participant.get("title") != title
                    title = participant.get("title")
                    @titleToIndex[title] = @titles.length
                    @titles.push title

            # Remove duplicates
            for index in dupIndices
                participants.splice(index, 1)

            @participants = participants #_.groupBy(participants, (x) -> x.get('title') )

            @participantThumbnails = $("#participantThumbnails")
            @participantThumbnailsOffset = @participantThumbnails.offset()


$( ->
        console.log "indepth_widget"
        indepthWidget = null
        getInstance = () ->
            if indepthWidget == null
                indepthWidget = new IndepthWidget({el: $("#indepth-widget"),model: window.combinedHistory})
                window.indepthWidget = indepthWidget
            indepthWidget
        window.pageModel.on 'ready-budget-history', ->
            getInstance().render()
        window.pageModel.on 'ready-participants', ->
            getInstance().setParticipants( window.pageModel.participants.models )
            getInstance().render()

)
