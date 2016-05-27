define(
  [
    'jquery',
    'backbone',
    'underscore',
    'scripts/bubble_chart',
    'Hasadna/oBudget/Misc/dataFetchers',
    'templates/main-budget-header.hbs',
    'templates/bubble-group-label.hbs',
    'templates/bubble-tooltip.html'
  ], ($, Backbone, _, BubbleChart, dataFetchers, tpl_main_budget_header, tpl_bubble_group_label, tpl_bubble_tooltip) ->

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
                y: 300

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

        constructor: (collection) ->
            # 2 digit prefix separation
            parentItems = collection.models
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

        constructor: (collection) ->
            items = collection.models
            items = _.filter(items, (x) -> x.get('group_top').length > 0 and x.get('code').substring(2,4)!='00')
            items = _.groupBy(items, (x) -> x.get('group_top')[0])
            groups = _.keys(items)
            groups = _.sortBy(groups, (x)-> -d3.sum(_.map(items[x], (y)->y.get('orig_2016'))))

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

        constructor: (collection) ->
            items = collection.models
            items = _.filter(items, (x) -> x.get('group_full').length > 0 and x.get('code').substring(2,4)!='00')
            items = _.groupBy(items, (x) -> x.get('group_full')[0])
            groups = _.keys(items)
            groups = _.sortBy(groups, (x)-> -d3.sum(_.map(items[x], (y)->y.get('orig_2016'))))

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

        initialize: (options) ->
            @options = options
            console.log("MainPageVis: initialize")
            @rendered = false

            @readyBudgetBubblesHandler()

            @readyMainBudgetHandler()

            window.addEventListener('resize', @resizedHandler.bind(this))


        events:
            'click #grouping-kind .btn': 'clickToggle'
            'click .compare-2016': 'compare_2016'
            'click .compare-2015': 'compare_2016_end'
            'click .compare-2015 .compare-year-start': 'compare_2016_start'
            'click .compare-2015 .compare-year-end': 'compare_2016_end'

        readyBudgetBubblesHandler: =>
          stateChange = (state, node) =>
              if (state == "initial")
                  @$bubbleContainer.find(".bubble-group-label").remove()
                  @$el.find("#grouping-kind").css("pointer-events", "").fadeTo(500, 1)
                  this.options.URLSchemeHandlerInstance.removeAttribute(
                      "focusOn", false
                  )
                  @chart.toggleColorLegend(@toggle == 0)
                  @chart.toggleCircleLegend(@toggle == 0)
                  @addBubbleLabels()
              else if (state == "centered")
                  @$bubbleContainer.find(".bubble-group-label").remove()
                  @$el.find("#grouping-kind").css("pointer-events", "none").fadeTo(500, 0)
                  @chart.toggleColorLegend(true)
                  @chart.toggleCircleLegend(true)
                  @addBubbleLabels(node)
          @chart = new BubbleChart(
              el: @$el.find("#bubble-chart"),
              addSubNodes: @addKids,
              stateChange: stateChange
          )
          @chart_el = d3.select(@chart.el)
          @$bubbleContainer = @$el.find("#bubble-chart-container")
          @centers = [
            new SimpleCentering(),
            new TopGroupCentering(@options.compareRecords),
            new FullGroupCentering(@options.compareRecords),
            new ParentCentering(@options.budgetItemKids)
          ]
          @prepareData()
          @toggle = 0
          if @options.URLSchemeHandlerInstance && @options.URLSchemeHandlerInstance.getAttribute('toggle')
              @toggle = parseInt(@options.URLSchemeHandlerInstance.getAttribute('toggle')) || 0
          @switchToggle(@toggle,false)
          @recalc_centers()
          @render()

          focusCode = this.options.URLSchemeHandlerInstance.getAttribute('focusOn')
          if focusCode
              @chart.focusOnCode(focusCode)

        resizedHandler: =>
          if @rendered
              @recalc_centers()
              @chart.start()

        readyMainBudgetHandler: =>
          @$el.find("#main-budget-header").html(tpl_main_budget_header({main:@options.mainBudgetItem.toJSON(), newb:@options.newBudgetItem.toJSON()}))
          if @rendered
              @compare_2016_start()

        compare_2016: =>
            @set_actives('.compare-2016')
            @switchComparison('orig_2016/rev_2016')

        compare_2016_start: =>
            @set_actives('.compare-year-start,.compare-2015')
            @switchComparison('orig_2015/orig_2016')
            false

        compare_2016_end: =>
            @set_actives('.compare-year-end,.compare-2015')
            @switchComparison('rev_2015/orig_2016')
            false

        set_actives: (selector) =>
            @$el.find('.compare-2016,.compare-2015,.compare-year-start,.compare-year-end').toggleClass('active',false)
            @$el.find(selector).toggleClass('active',true)

        clickToggle: (e) =>
            toggle = parseInt($(e.currentTarget).attr('data-toggle'))
            console.log $(e.currentTarget).attr('data-toggle')
            console.log toggle
            toggle = toggle || 0
            if toggle != @toggle
                @switchToggle(toggle,true)
            false

        switchToggle: (toggle,update) =>

            d3.select(@vis).selectAll(".bubbleTitle#{@toggle}")
                        .transition()
                        .style('opacity', 0)

            @toggle = toggle

            if update
                @options.URLSchemeHandlerInstance.addAttribute("toggle", @toggle, false)

            # Add URL attribute
            d3.select(@vis).selectAll(".bubbleTitle#{@toggle}")
                        .transition()
                        .style('opacity', 1)

            $("#grouping-kind").find("label").toggleClass("active",false)
            $("#grouping-kind").find("label[data-toggle="+@toggle+"]").toggleClass("active",true)

            @recalc_centers()
            @chart.start()

            @chart.toggleColorLegend(@toggle == 0)
            @chart.toggleCircleLegend(@toggle == 0)

        addBubbleLabels: (centeredNode) ->
          # Check if labels already exist
          @$bubbleContainer.find(".bubble-group-label").remove()
          center = @centers[@toggle]
          title_data = center.getCenters()

          tpl_total_coefficient = 1000 # TODO: should this be a constant defined somewhere else?

          if centeredNode?
              $(tpl_bubble_group_label({
                    total: centeredNode.rev * tpl_total_coefficient,
                    title: centeredNode.src.get("title")
                })).css({
                    top: "50px",
                    left: @$bubbleContainer.width()/2 + "px"
                }).appendTo(@$bubbleContainer)

          else
              for group, i in title_data
                if group.title?
                  group.total = group.total * tpl_total_coefficient

                  $(tpl_bubble_group_label(group)).css({
                    top: (group.y + @chart.radius_scale(group.total/tpl_total_coefficient)) + "px",
                    left: group.x + "px"
                  }).appendTo(@$bubbleContainer)
                  console.log('GROUP',group);


        addKids: (node, readyCallback) =>
            year = node.src.get('year')
            code = node.src.get('code')
            dataFetchers.budgetItemKids(code, year)
              .then( (centeredNodeKids) =>
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
                        tooltip_contents: -> tpl_bubble_tooltip(@)
                        center: null
                        part: 0
                        subNode: true
                        click: (d) =>
                            console.log "click", d, model
                            window.location.hash = @options.URLSchemeHandlerInstance.linkToBudget(d.id, model.get('year'))

                    kidNodes.push(node)

                readyCallback(kidNodes)
              );

        prepareData: ->
            fill_color = -> "#aabbcc"
            stroke_color = -> "#ccbbaa"

            # Create data for bubble chart
            @data = []
            that = @
            for model in @options.compareRecords.models
                if model.get('code').substring(2,4)=="00"
                    continue
                node =
                    id: model.get('code')
                    src: model
                    value: 1
                    className: -> "bubblesCircle "+changeClass(this.orig,this.rev)+"_svg"
                    fill_color: null
                    stroke_color: null
                    tooltip_contents: -> tpl_bubble_tooltip(this)
                    center: null,
                    onMoreInfo: @moreInfo,
                    click: (d) =>
                        this.options.URLSchemeHandlerInstance.addAttribute(
                            "focusOn", d.src.get("code"), false
                        )
                        @addBubbleLabels(d)
                @data.push node

            @compare_2016_start()

        moreInfo: (node) ->
            code = @src.get('code')
            year = @src.get('year')
            window.location.hash = @options.URLSchemeHandlerInstance.linkToBudget(code, year)
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
                if node.rev >= node.orig then increased += 1
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

    MainPageVis
)
