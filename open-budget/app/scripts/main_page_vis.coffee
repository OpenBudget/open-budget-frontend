define(['jquery','backbone', 'models', 'templates', 'bubble_chart'], ($, Backbone, models, JST, BubbleChart) ->

    globalWidth = 0

    `
    console = console || {}; // just in case
    console.watch = function(oObj, sProp, targetVal) {
       sPrivateProp = "$_"+sProp+"_$"; // to minimize the name clash risk
       oObj[sPrivateProp] = oObj[sProp];

       // overwrite with accessor
       Object.defineProperty(oObj, sProp, {
           get: function () {
               return oObj[sPrivateProp];
           },

           set: function (value) {
               //console.log("setting " + sProp + " to " + value);
               debugger; // sets breakpoint
               oObj[sPrivateProp] = value;
           }
       });
    }
    `

    class BaseCentering

        setFocusedCenter: ($el) ->
            @focusedCenter =
                index: 0
                category: -> "focused"
                x: $el.width()/2
                y: @item_height/2

            @focusedCenter

    class SimpleCentering extends BaseCentering

        constructor: ->
            @center =
                index: 0
                category: -> "aaa"

        getCenters: -> [@center]
        elToCenter: (el) -> @center
        item_width: 600
        item_height: 600

    class ParentCentering extends BaseCentering

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

    class TopGroupCentering extends BaseCentering

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


    class FullGroupCentering extends BaseCentering

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
            console.log("MainPageVis: initialize")
            @rendered = false
            @model.on 'ready-budget-bubbles', =>
                console.log("MainPageVis: Received event ready-budget-bubbles")
                @chart = new BubbleChart(
                    el: @$el.find("#bubble-chart"),
                    addSubNodes: @addKids,
                    stateChange: (state) =>
                        if (state == "initial")
                            @$bubbleContainer.find(".bubble-group-label").remove()
                            @$el.find("#grouping-kind").css("pointer-events", "").fadeTo(500, 1)
                            models.pageModel.URLSchemeHandlerInstance.removeAttribute(
                                "focusOn", false
                            )
                        else if (state == "centered")
                            @$el.find("#grouping-kind").css("pointer-events", "none").fadeTo(500, 0)
                )
                @chart_el = d3.select(@chart.el)
                @$bubbleContainer = @$el.find("#bubble-chart-container")
                @centers = [ new SimpleCentering(), new TopGroupCentering(), new FullGroupCentering(), new ParentCentering() ]
                @prepareData()
                @toggle = 0
                if @model.URLSchemeHandlerInstance && @model.URLSchemeHandlerInstance.getAttribute('toggle')
                    @toggle = parseInt(@model.URLSchemeHandlerInstance.getAttribute('toggle')) || 0
                    $("#grouping-kind").find("label[data-toggle="+@toggle+"]").trigger("click")
                @recalc_centers()
                @render()

                focusCode = models.pageModel.URLSchemeHandlerInstance.getAttribute('focusOn')
                if focusCode
                    @chart.focusOnCode(focusCode)

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

        addBubbleLabels: (centeredNode) ->
          # Check if labels already exist
          @$bubbleContainer.find(".bubble-group-label").remove()
          center = @centers[@toggle]
          title_data = center.getCenters()

          if centeredNode?
              $(JST.bubble_group_label({
                    total: centeredNode.rev,
                    title: centeredNode.src.get("title")
                })).css({
                    top: "50px",
                    left: @$bubbleContainer.width()/2 + "px"
                }).appendTo(@$bubbleContainer)

          for group, i in title_data
            if group.title?
              $(JST.bubble_group_label(group)).css({
                top: (group.y - center.item_height/2) + "px",
                left: group.x + "px"
              }).appendTo(@$bubbleContainer)

        addKids: (node, readyCallback) =>
            code = node.src.get('code')
            # TODO get the year from the model
            year = 2014
            centeredNodeKids = new pageModel.api.BudgetItemKids([], year: year, code: code, pageModel: pageModel)
            centeredNodeKids.on('sync', =>
                console.log("kids are ready")
                kidNodes = []
                for model in centeredNodeKids.models
                    node =
                        id: model.get('code')
                        src: model
                        orig: model.get('net_allocated')
                        rev:  model.get('net_revised')
                        onMoreInfo: @moreInfo
                        value: model.get('net_revised')
                        className: -> "child-bubble "+changeClass(this.orig,this.rev)+"_svg"
                        fill_color: null
                        stroke_color: null
                        tooltip_contents: -> JST.bubble_tooltip(@)
                        center: null,
                        part: 0,
                        subNode: true

                    kidNodes.push(node)

                readyCallback(kidNodes)
            )

        prepareData: ->
            fill_color = -> "#aabbcc"
            stroke_color = -> "#ccbbaa"

            # Create data for bubble chart
            @data = []
            that = @
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
                    center: null,
                    onMoreInfo: @moreInfo,
                    click: (d) =>
                        models.pageModel.URLSchemeHandlerInstance.addAttribute(
                            "focusOn", d.src.get("code"), false
                        )
                        @addBubbleLabels(d)
                @data.push node

            @compare_2014()

        moreInfo: (node) ->
            # TODO get the year from the model
            year = 2014
            window.location.hash = pageModel.URLSchemeHandlerInstance.linkToBudget(@id, year)
            ###
            TODO: build a new view controller architecture

            code = @src.get('code')
            pageModel.switchView({
                kind: "budget",
                flow: "main",
                code: code,
                year: @src.get('year')
            })
            ###

        switchComparison: (selected) =>
            console.log 'switchComparison'
            @selectedComparison = selected

            scaling = 20.0
            [orig_field, rev_field] = @selectedComparison.split('/')
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

        recalc_centers: () =>
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

            @chart.updateFocusCenter(center_strategy.setFocusedCenter(@$el))
            for node in @data
                node.center = center_strategy.elToCenter(node)
                # Accumulate the total allocated budget for each center
                if node.center? then node.center.total += node.rev

                if node.center?.x? or node.center?.y?
                    @nodes.push node

            @chart.updateNodes(@nodes, @centers[@toggle].getCenters().length, @centeredNode)

            # We need to refresh the bubble labels based on the new centers
            @addBubbleLabels()

            d3.select(@el).selectAll(".bubbleTitle#{@toggle}")
                            .data(@centers[@toggle].getCenters())
                            .transition()
                            .style('opacity', 1)
                            .attr('x', (d) -> d.x)
                            .attr('y', (d) -> d.y)

        render: ->
            #@chart.render()
            #@chart.start()
            @rendered = true

    console.log "main_page"

    mainPageVis = new MainPageVis({el: $("#main-page-article"), model: models.pageModel });
    window.mainPageVis = mainPageVis
    return mainPageVis
)
