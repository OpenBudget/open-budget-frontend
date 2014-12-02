globalWidth = 0

class SimpleCentering

    constructor: ->
        @center =
            index: 0
            category: -> "aaa"

    getCenters: -> [@center]
    elToCenter: (el) -> @center
    item_width: 600
    item_height: 600
    title_dy: 1

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
                        index: i
                        title: el.get('title')
                        category: -> "aaa"+i
        )
        @data = _.values(@centers)

    getCenters: => @data
    elToCenter: (el) => @centers[el.id.substring(2,4)]
    item_width: 200
    item_height: 250
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
                        index: i
                        title: el
                        category: -> "aaa"+i
        )
        @data = _.values(@centers)

    getCenters: => @data
    elToCenter: (el) => @centers[el.src.get('group_top')[0]]
    title_dy: 150
    item_width: 400
    item_height: 300


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
                        index: i
                        title: el
                        category: -> "aaa"+i
        )
        @data = _.values(@centers)

    getCenters: => @data
    elToCenter: (el) => @centers[el.src.get('group_full')[0]]
    title_dy: 100
    item_width: 300
    item_height: 250


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
            @$el.find("#main-budget-header").html(JST.main_budget_header(@model.mainBudgetItem.toJSON()))
            if @rendered
                @switchComparison()
        @model.on 'resized', =>
            if @rendered
                @recalc_centers()
                @chart.start()


    events:
        'click #grouping-kind .btn': 'switchToggle'
        'change #comparison-kind': 'switchComparison'

    switchToggle: (e) =>
        d3.select(@el).selectAll(".bubbleTitle#{@toggle}")
                    .transition()
                    .style('opacity', 0)
        console.log $(e.currentTarget).attr('data-toggle')
        @toggle = parseInt($(e.currentTarget).attr('data-toggle'))
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
                    window.location.hash = linkToBudget(this.id,window.pageModel.get('year'))
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
        increased = 0
        decreased = 0
        for node in @data
            model = node.src
            node.orig = model.get(orig_field)
            node.rev = model.get(rev_field)
            if node.orig > node.rev then decreased += 1
            if node.rev > node.orig then increased += 1
            node.value = node.rev
            node.part = 1.0*node.rev/node.orig-1
            if node.part > 0 then node.part = d3.min([1,node.part / scaling])
        $("#num-items-increased").text(""+increased)
        $("#num-items-decreased").text(""+decreased)
        $("div.main-budget-title").toggleClass('hide',true)
        $("div.main-budget-title[id='#{selected}']").toggleClass('hide',false)
        if @rendered
            @chart.reapply_values()
            @chart.start()

    recalc_centers: =>
        globalWidth = @$el.width()
        @nodes = []
        center_strategy = @centers[@toggle]
        centers = center_strategy.getCenters()
        items_in_line = d3.max([Math.floor(globalWidth / center_strategy.item_width), 1])
        items_in_line = d3.min([items_in_line,centers.length])
        start_x = (globalWidth - (items_in_line-1)*center_strategy.item_width)/2
        start_y = center_strategy.item_height/2

        globalHeight = Math.ceil(centers.length/items_in_line) * center_strategy.item_height + 30
        @chart.setHeight(globalHeight)

        for center in centers
            center.x = (center.index % items_in_line)*center_strategy.item_width + start_x
            center.y = (Math.floor(center.index / items_in_line))*center_strategy.item_height + start_y

        for node in @data
            node.center = center_strategy.elToCenter(node)
            if node.center?.x? or node.center?.y?
                @nodes.push node
        @chart.updateNodes(@nodes, @centers[@toggle].getCenters().length)
        d3.select(@el).selectAll(".bubbleTitle#{@toggle}")
                        .data(@centers[@toggle].getCenters())
                        .transition()
                        .style('opacity', 1)
                        .attr('x', (d) -> d.x)
                        .attr('y', (d) -> d.y)

    render: ->
        @chart.render()
        @chart.start()
        @rendered = true

$( ->
    console.log "main_page"
    window.mainPageVis = new MainPageVis({el: $("#main-page-article"), model: window.pageModel });
)
