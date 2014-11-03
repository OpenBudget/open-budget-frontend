class MainPageVis extends Backbone.View

    initialize: ->
        @model.on 'ready-budget-bubbles', =>
            @toggle = false
            @prepareData()
            @recalc_centers()
            @render()

    events:
        'click': 'switchToggle'

    switchToggle: ->
        @toggle = !@toggle
        d3.select(@el).selectAll('.bubblesMinistryTitle')
                    .transition()
                    .style('opacity', if @toggle then 1 else 0)
        @recalc_centers()
        @chart.start()

    prepareData: ->
        fill_color = -> "#aabbcc"
        stroke_color = -> "#ccbbaa"

        # 2 digit prefix separation
        parentItems = pageModel.budgetItems2.models
        parentItems = _.sortBy( parentItems, (x) -> -x.get('net_revised') )
        parentItems = _.filter( parentItems, (x) -> x.get('code').substring(2,4) != "00" )
        parentItems = _.filter( parentItems, (x) -> x.get('net_revised')>0 )

        @centers = {}
        _.each( parentItems
               ,
                (el,i) =>
                    code = el.get('code').substring(2,4)
                    @centers[code] =
                        x: i%6 * 200 + 150,
                        y: Math.floor(i/6) * 250 + 250
                        title: el.get('title')
        )
        title_data = _.values(@centers)
        d3.select(@el).selectAll('.bubblesMinistryTitle')
                    .data(title_data)
                    .enter()
                    .append('svg:text')
                    .attr('class','bubblesMinistryTitle')
                    .attr('x', (d) -> d.x)
                    .attr('y', (d) -> d.y)
                    .attr('dy', 100)
                    .text((d) -> d.title)
                    .style('opacity', 0)
                    .style("text-anchor", "middle")

        # Create data for bubble chart
        @data = []
        @scaling = 20.0
        that = this
        for model in pageModel.budgetItems4.models
            if !@centers[model.get('code').substring(2,4)]?
                continue

            orig = model.get('net_allocated')
            revised = model.get('net_revised')
            if !(orig>0) || !(revised>0)
                continue
            part = 1.0*revised/orig-1
            #if part > 0 then part = d3.min([1,part / @scaling])

            node =
                id: model.get('code')
                category: -> if that.toggle then this.id.substring(0,4) else ""
                src: model
                value: revised
                orig: orig
                rev: revised
                part: part
                className: -> "bubblesCirle "+changeClass(this.orig,this.rev)+"_svg"
                fill_color: null
                stroke_color: null
                tooltip_contents: -> JST.bubble_tooltip(this)
                click: ->
                    window.location.hash = linkToBudget(this.id,this.src.get('year'))
                    false
                center: null
            @data.push node


    recalc_centers: ->
        width = @$el.width()
        for node in @data
            if @toggle
                    node.center = @centers[node.id.substring(2,4)]
                else
                    node.center = { x: width/2, y: 300 }

    render: ->
        @chart = new BubbleChart( el: @el, data: @data, numParts: -> if @toggle then 63 else 1 )
        @chart.render()
        @chart.start()

$( ->
    console.log "main_page"
    window.mainPageVis = new MainPageVis({el: $("#bubble-chart"), model: window.pageModel });
)
