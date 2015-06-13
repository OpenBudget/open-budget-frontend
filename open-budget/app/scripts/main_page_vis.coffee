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
    item_width: 300
    item_height: 250


class MainPageVis extends Backbone.View

    initialize: ->
        @rendered = false
        @model.on 'ready-budget-bubbles', =>
            @chart = new BubbleChart( el: @$el.find("#bubble-chart") )
            @chart_el = d3.select(@chart.el)
            @$bubbleContainer = @$el.find("#bubble-chart-container");
            @centers = [ new SimpleCentering(), new TopGroupCentering(), new FullGroupCentering(), new ParentCentering() ]
            @prepareData()
            @toggle = 0
            if @model.URLSchemeHandlerInstance && @model.URLSchemeHandlerInstance.getAttribute('toggle')
                @toggle = parseInt(@model.URLSchemeHandlerInstance.getAttribute('toggle')) || 0
                $("#grouping-kind").find("label[data-toggle="+@toggle+"]").trigger("click")
            @recalc_centers()
            @render()

        @model.on 'ready-main-budget', =>
            @$el.find("#main-budget-header").html(JST.main_budget_header({main:@model.mainBudgetItem.toJSON(), newb:@model.newBudgetItem.toJSON()}))
            if @rendered
                @compare_2014()
        @model.on 'resized', =>
            if @rendered
                @recalc_centers()
                @chart.start()


    events:
        'click #grouping-kind .btn': 'switchToggle'
        'click .compare-2014': 'compare_2014'
        # 'click .compare-2015': 'compare_2015_start'
        # 'click .compare-2015 .compare-year-start': 'compare_2015_start'
        # 'click .compare-2015 .compare-year-end': 'compare_2015_end'

    compare_2014: =>
        @set_actives('.compare-2014')
        @switchComparison('orig_2014/rev_2014')

    compare_2015_start: =>
        @set_actives('.compare-year-start,.compare-2015')
        @switchComparison('orig_2014/orig_2015')
        false

    compare_2015_end: =>
        @set_actives('.compare-year-end,.compare-2015')
        @switchComparison('rev_2014/orig_2015')
        false

    set_actives: (selector) =>
        @$el.find('.compare-2014,.compare-2015,.compare-year-start,.compare-year-end').toggleClass('active',false)
        @$el.find(selector).toggleClass('active',true)

    switchToggle: (e) =>
        d3.select(@el).selectAll(".bubbleTitle#{@toggle}")
                    .transition()
                    .style('opacity', 0)
        console.log $(e.currentTarget).attr('data-toggle')
        @toggle = parseInt($(e.currentTarget).attr('data-toggle'))
        # Add URL attribute
        @model.URLSchemeHandlerInstance.addAttribute("toggle", @toggle, false)

        @recalc_centers()
        @chart.start()

    addBubbleLabels: ->
      # Check if labels already exist
      @$bubbleContainer.find(".bubble-group-label").remove();
      center = @centers[@toggle]
      title_data = center.getCenters()
      for group, i in title_data
        if group.title?
          $(JST.bubble_group_label(group)).css({
            top: (group.y - center.item_height/2) + "px",
            left: group.x + "px"
          }).appendTo(@$bubbleContainer);


    prepareData: ->
        fill_color = -> "#aabbcc"
        stroke_color = -> "#ccbbaa"

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
                    window.location.hash = pageModel.URLSchemeHandlerInstance.linkToBudget(this.id,2015)
                    false
                center: null
            @data.push node
        @compare_2014()

    switchComparison: (selected) =>
        console.log 'switchComparison'
        scaling = 20.0
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
            if node.orig <=0 and node.rev <= 0
                node.part = 0
            else if node.orig == 0
                node.part = 0
            else
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
        start_y = center_strategy.item_height/2

        globalHeight = Math.ceil(centers.length/items_in_line) * center_strategy.item_height + 30
        @chart.setHeight(globalHeight)

        for center in centers
            if center.index >= (Math.floor(centers.length/items_in_line)*items_in_line)
                start_x = (globalWidth - ((centers.length % items_in_line)-1)*center_strategy.item_width)/2
            else
                start_x = (globalWidth - (items_in_line-1)*center_strategy.item_width)/2

            center.x = globalWidth - ((center.index % items_in_line)*center_strategy.item_width + start_x)
            center.y = (Math.floor(center.index / items_in_line))*center_strategy.item_height + start_y
            center.total = 0

        for node in @data
            node.center = center_strategy.elToCenter(node)
            # Accumulate the total allocated budget for each center
            if node.center? then node.center.total += node.rev
            if node.center?.x? or node.center?.y?
                @nodes.push node
        @chart.updateNodes(@nodes, @centers[@toggle].getCenters().length)

        # We need to refresh the bubble labels based on the new centers
        @addBubbleLabels()

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
