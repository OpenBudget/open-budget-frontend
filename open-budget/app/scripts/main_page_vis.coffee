globalWidth = 0

class SimpleCentering

    getCenters: -> [{ x: 300, y: 300 }]
    elToCenter: (el) -> { x: globalWidth/2, y: 300, category: -> "aaa" }

class ParentCentering

    constructor: ->
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
                        category: -> "aaa"+i
        )
        @data = _.values(@centers)

    getCenters: => @data
    elToCenter: (el) => @centers[el.id.substring(2,4)]
    title_dy: 100

class TopGroupCentering

    constructor: ->
        items = pageModel.budgetItems4.models
        items = _.filter(items, (x) -> x.get('group_top').length > 0 and x.get('code').substring(2,4)!='00')
        items = _.groupBy(items, (x) -> x.get('group_top')[0])
        groups = _.keys(items)
        groups = _.sortBy(groups, (x)-> -d3.sum(_.map(items[x], (y)->y.get('orig_2015'))))

        @centers = {}
        _.each( groups
               ,
                (el,i) =>
                    @centers[el] =
                        x: i%3 * 400 + 150,
                        y: Math.floor(i/3) * 300 + 250
                        title: el
                        category: -> "aaa"+i
        )
        @data = _.values(@centers)

    getCenters: => @data
    elToCenter: (el) => @centers[el.src.get('group_top')[0]]
    title_dy: 150

class FullGroupCentering

    constructor: ->
        items = pageModel.budgetItems4.models
        items = _.filter(items, (x) -> x.get('group_full').length > 0 and x.get('code').substring(2,4)!='00')
        items = _.groupBy(items, (x) -> x.get('group_full')[0])
        groups = _.keys(items)
        groups = _.sortBy(groups, (x)-> -d3.sum(_.map(items[x], (y)->y.get('orig_2015'))))

        @centers = {}
        _.each( groups
               ,
                (el,i) =>
                    @centers[el] =
                        x: i%4 * 300 + 150,
                        y: Math.floor(i/4) * 250 + 250
                        title: el
                        category: -> "aaa"+i
        )
        @data = _.values(@centers)

    getCenters: => @data
    elToCenter: (el) => @centers[el.src.get('group_full')[0]]
    title_dy: 100


class MainPageVis extends Backbone.View

    initialize: ->
        @rendered = false
        @model.on 'ready-budget-bubbles', =>
            @chart = new BubbleChart( el: @$el.find("#bubble-chart") )
            @chart_el = d3.select(@chart.el)
            @toggle = 0
            @centers = [ new SimpleCentering(), new TopGroupCentering(), new FullGroupCentering(), new ParentCentering() ]
            @prepareData()
            @recalc_centers()
            @render()
        @model.on 'ready-main-budget', =>
            console.log 'ready-main-budget'
            @$el.find("#main-budget-header").html(JST.main_budget_header(@model.mainBudgetItem.toJSON()))

    events:
        'click #grouping-kind .btn': 'switchToggle'
        'change #comparison-kind': 'switchComparison'

    switchToggle: (e) =>
        d3.select(@el).selectAll(".bubbleTitle#{@toggle}")
                    .transition()
                    .style('opacity', 0)
        console.log $(e.currentTarget).attr('data-toggle')
        @toggle = parseInt($(e.currentTarget).attr('data-toggle'))
        d3.select(@el).selectAll(".bubbleTitle#{@toggle}")
                    .transition()
                    .style('opacity', 1)
        @recalc_centers()
        @chart.start()

    prepareData: ->
        fill_color = -> "#aabbcc"
        stroke_color = -> "#ccbbaa"

        for center,i in @centers
            title_data = center.getCenters()
            @chart_el.selectAll(".bubbleTitle#{i}")
                        .data(title_data)
                        .enter()
                            .append('svg:text')
                            .attr('class',"bubbleTitle bubbleTitle#{i}")
                            .attr('x', (d) -> d.x)
                            .attr('y', (d) -> d.y)
                            .attr('dy', center.title_dy)
                            .text((d) -> d.title)
                            .style('opacity', 0)
                            .style("text-anchor", "middle")

        # Create data for bubble chart
        @data = []
        that = this
        for model in pageModel.budgetItems4.models
            # orig = model.get('orig_2014')
            # revised = model.get('orig_2015')
            # if !(orig>0) || !(revised>0)
            #     continue
            if model.get('code').substring(2,4)=="00"
                continue

            node =
                id: model.get('code')
                src: model
                value: 1
                className: -> "bubblesCircle "+changeClass(this.orig,this.rev)+"_svg"
                fill_color: null
                stroke_color: null
                tooltip_contents: -> JST.bubble_tooltip(this)
                click: ->
                    window.location.hash = linkToBudget(this.id,this.src.get('year'))
                    false
                center: null
            @data.push node
        @switchComparison()

    switchComparison: =>
        console.log 'switchComparison'
        scaling = 20.0
        selected = @$el.find("#comparison-kind").val()
        [orig_field, rev_field] = selected.split('/')
        console.log orig_field, rev_field
        for node in @data
            model = node.src
            node.orig = model.get(orig_field)
            node.rev = model.get(rev_field)
            node.value = node.rev
            node.part = 1.0*node.rev/node.orig-1
            if node.part > 0 then node.part = d3.min([1,node.part / scaling])
        if @rendered
            @chart.reapply_values()
            @chart.start()

    recalc_centers: =>
        globalWidth = @$el.width()
        @nodes = []
        for node in @data
            node.center = @centers[@toggle].elToCenter(node)
            if node.center?.x? or node.center?.y?
                @nodes.push node
        @chart.updateNodes(@nodes, @centers[@toggle].getCenters().length)

    render: ->
        @chart.render()
        @chart.start()
        @rendered = true

$( ->
    console.log "main_page"
    window.mainPageVis = new MainPageVis({el: $("#main-page-article"), model: window.pageModel });
)
