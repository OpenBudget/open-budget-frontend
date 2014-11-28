class BudgetPartitionLayoutView extends Backbone.View

    BACK_WIDTH = 100

    initialize: ->
        @render()
        @codes = {}

    render: ->

        @vis = d3.select(@el)
                .append("svg:svg")
        @partition = d3.layout.partition()
                            .value((d) -> d.s) #net_allocated)
                            .children((d) -> d.k)
        @change_tip = d3.tip()
                       .attr('class', 'd3-tip search-bar-tip')
                       .direction("e")
                       .offset((d) => [500,1])
                       .html((d) -> JST.searchbar_tooltip(d))
        @vis.call(@change_tip)
        @treemap = @vis.append('g')
                        .attr("class","treemap")
        @highlightor = @vis.append('rect')
                            .style('fill','none')
                            .style('stroke','white')
                            .style('stroke-width','2px')
                            .style('stroke-location','inside')
        @expandor = @vis.append('g')
                        .attr("class","expandor")
                        .style('visibility','hidden')
        @expandor.append('rect')
                        .style('stroke','none')
                        .style('fill','#888')
        @expandor.append('g')
                        .attr("class","icon")
                        .html(JST.expandor_icon())
                        .on("click", () =>
                                console.log "click", @selected_tooltip
                                if @selected_tooltip?
                                    @hide_tip()
                                    @selectCode(@selected_tooltip,true)
                                false
                        )
        @upbacker = @vis.append('g')
                        .attr("class","upbacker")
                        .style('visibility','hidden')
                        .html(JST.upbacker())
        @upbacker.on("click", () =>
                                console.log "click", @selected_tooltip
                                if @selected_tooltip? and @selected_tooltip.length > 2
                                    console.log @selected_tooltip.slice(0,-2)
                                    @hide_tip()
                                    @selectCode(@selected_tooltip.slice(0,-2),true)
                                false
                        )


        @selected_tooltip = ""
        @show_tip = (d) =>
            @selected_tooltip = d.c
            if d.c == @root.c
                @hide_tip()
                if d.c != '00'
                    @upbacker.attr("transform", "translate(" + @w + "," + 0 + ")" )
                             .style('visibility','visible')
                             .attr("class","upbacker #{ @cls(d) }") 
                return
            @change_tip.show(d)
            @expandor.attr("transform", "translate(" + @x(d.y+d.dy) + "," + (@y(d.x)+1) + ")" )
                    .style('visibility','visible')
                    .attr("class","expandor #{ @cls(d) }")
            @expandor.select('rect')
                     .attr("width", 50)
                     .attr("height", d3.max([0,@y(d.dx) - @y(0)-2]))
            @expandor.select('g.icon')
                     .attr('transform', "translate("+0+","+(@y(d.dx/2) - @y(0))+")")
            @upbacker.style('visibility','hidden')
            @highlightor.attr("height", @y(d.dx) - @y(0))
                        .attr("width", @x(d.y))
                        .attr("y", @y(d.x))
                        .style("visibility","visible")
            $(".search-bar-tip").toggleClass('active',true)


            window.setTimeout(
                =>
                    if d.c == @selected_tooltip
                        bl = new window.models.BudgetItem(pageModel: window.pageModel)
                        bl.set('year',window.pageModel.get('year'))
                        bl.set('code',d.c)
                        bl.on('change', ->
                            $("#search-tip[data-code=#{d.c}]").html(JST.searchbar_tooltip_full(bl.toJSON()))
                        )
                        bl.do_fetch()
               ,
                250
            )
        @hide_tip = =>
            @change_tip.hide()
            @expandor.style('visibility','hidden')
            @upbacker.style('visibility','hidden')
            @highlightor.style("visibility","hidden")
            $(".search-bar-tip").toggleClass('active',false)

        @cls = (d,suffix="") => window.changeClass( d.value, d.value*(d.o+100)/100.0 ) + suffix

        onSuccess = (root) =>

            @root = root.value
            @data = @partition.nodes(@root)

            @codes = {}
            for datum in @data
                @codes[datum.c] = datum

            @updateChart()

        $.ajax(
            dataType: window.pageModel.get('dataType')
            url: "#{window.pageModel.get('baseURL')}/api/sysprop/static-budget"
            success: onSuccess
        )

    gotoBudgetItem: (code) =>
        window.location.hash = window.linkToBudget(code,window.pageModel.get('year'))
        window.location.reload()


    updateChart: (transition) =>
        if not transition?
            transition = false
        console.log "PL","updateChart"
        @w = @$el.width()-15
        @h = 400 # @$el.height()

        console.log "PL","updateChart #{@w} x #{@h}"

        @$el.find('svg')
            .attr('width', @w)
            .attr('height', @h)

        @x = d3.scale.linear().domain([@root.y+@root.dy/2,@root.y+@root.dy*3]).range([@w-BACK_WIDTH, 0])
        @y = d3.scale.linear().domain([@root.x,@root.x+@root.dx]).range([10, @h-10])

        transform = (d) => "translate(" + (-8 - @x(d.dy) + @x(0) ) +  "," + (@y(d.dx / 2) - @y(0)) + ")"

        _data = _.filter(@data, (d) => d.depth - @root.depth < 3)
        g_all = @treemap.selectAll("g").data(_data, (d)->d.c)
        g = g_all.enter().append("svg:g")
                # .on("click", click)
        g.attr("data-code", (d) -> d.c)

        g.append("svg:rect")
            .attr("class", (d) => (if d.k? then "parent" else "child") + " " + @cls(d,'_bg') )
            .on("click", (d) => if d.k? then @gotoBudgetItem(d.c) )
        g.append("svg:text")
            .attr("dy", ".35em")
            .text((d) -> d.n)
        g.on('mouseover', (d) => @show_tip(d))
        #.on('mouseout', (d) => @change_tip.hide(d))

        g_all.exit().remove()

        t = g_all
        if transition
            console.log "will transition!"
            t = t.transition()
                 .duration(750)
        t = t.attr("transform", (d) => "translate(" + @x(d.y+d.dy) + "," + @y(d.x) + ")" )
        t.select("rect")
            .attr("width", Math.abs(@x(@root.dy) - @x(0)))
            .attr("height", (d) => @y(d.dx) - @y(0))
        t.select("text")
            .attr("transform", transform)
            .attr("dx", (d) => if d.y == @root.y then @x(@root.dy/2) - @x(0) else 0)
            .attr("class", (d) => if @y(d.dx) - @y(0) > 12 then "big-title" else "small-title")

            # d3.select(@el) # window
            #     .on("click", () -> click(root))

    selectCode: (code, transition) =>
        if not transition?
            transition = false
        d = null
        code = code.slice(0,6)
        while code != '' and not d?
            d = @codes[code]
            if not d?
                code = code.slice(0,-2)

        if d?
            console.log d
            @root = d
            @updateChart(transition)

class SearchBar extends Backbone.View

    STATE_IDLE = 'idle'
    STATE_OPEN = 'open'
    STATE_RESULTS = 'results'
    STATE_CLOSED_RESULTS = 'cl_results'

    EV_OPEN_DROPDOWN = "open"
    EV_TOGGLE_DROPDOWN = "toggle"
    EV_CLOSE_DROPDOWN = "close"
    EV_CLEAR_RESULTS = "clear"
    EV_GOT_RESULTS = "results"

    events:
        "submit form": "selectionHandler"
        "click #btn-tree": "treeBtnClick"
        "click #search-item": "headerClick"
        "input #search-item": "getSuggestions"
        "keydown #search-item": "searchBarKeyHandler"
        "click .search-dropdown-item": "itemSelectedHandler"

    transition: (event) =>
        switch @state
            when STATE_IDLE
                switch event
                    when EV_OPEN_DROPDOWN, EV_TOGGLE_DROPDOWN
                        @openDropdown()
                        if window.pageModel.get('budgetCode')?
                            @partition.selectCode( window.pageModel.get('budgetCode') )
                        @state = STATE_OPEN
            when STATE_CLOSED_RESULTS
                switch event
                    when EV_OPEN_DROPDOWN, EV_TOGGLE_DROPDOWN
                        @openDropdown()
                        @createSuggestionPane()
                        @renderSuggestions()
                        @state = STATE_RESULTS
            when STATE_OPEN
                switch event
                    when EV_GOT_RESULTS
                        @createSuggestionPane()
                        @renderSuggestions()
                        @state = STATE_RESULTS
                    when EV_CLOSE_DROPDOWN, EV_TOGGLE_DROPDOWN
                        @closeDropdown()
                        @state = STATE_IDLE
            when STATE_RESULTS
                switch event
                    when EV_CLOSE_DROPDOWN, EV_TOGGLE_DROPDOWN
                        @closeDropdown()
                        @state = STATE_CLOSED_RESULTS
                    when EV_CLEAR_RESULTS
                        @clearSuggestions()
                        @state = STATE_OPEN
                    when EV_GOT_RESULTS
                        @renderSuggestions()

    isOpen: () =>
        @state == STATE_OPEN || @state == STATE_RESULTS

    openDropdown: =>
        setTimeout( () =>
                     if @isOpen()
                        @$el.find('.search-partition-layout').css('display','inherit')
                   ,
                    500
        )
        @$el.find('#search-item').focus()
        @dropdown.toggleClass('active',true)

    closeDropdown: =>
        @$el.find('.search-partition-layout').css('display','none')
        @dropdown.toggleClass('active',false)

    clearSuggestions: () =>
        @$el.find(".search-results").html('')
        @$el.find("#search-dropdown").toggleClass('gotresults',false)
        @$el.find("#search-dropdown .search-partition-layout").toggleClass('col-md-8',false)
        @$el.find("#search-dropdown .search-partition-layout").toggleClass('col-md-12',true)
        @partition.updateChart()

    createSuggestionPane: () =>
        @$el.find("#search-dropdown").toggleClass('gotresults',true)
        @$el.find("#search-dropdown .search-partition-layout").toggleClass('col-md-8',true)
        @$el.find("#search-dropdown .search-partition-layout").toggleClass('col-md-12',false)
        @partition.updateChart()

    renderSuggestions: () =>
        sr = @$el.find('.search-results')
        sr.html('')
        for suggestion in @suggestions
            item = $(JST.search_dropdown_item(suggestion))
            sr.append(item)
            item.data(suggestion)

    treeBtnClick: (event) =>
        console.log('treeBtnClick')
        event.preventDefault()
        @transition(EV_TOGGLE_DROPDOWN)

    headerClick: (event) =>
        event.preventDefault()
        @transition(EV_OPEN_DROPDOWN)

    getSuggestions: (event) =>
        event.preventDefault()
        val = @$el.find('#search-item').val()
        console.log 'getSuggestions',val
        if val != ''
            @transition(EV_OPEN_DROPDOWN)
            @engine.get( val
                        ,
                         (suggestions) =>
                            @suggestions = suggestions
                            @suggestionNum = suggestions.length
                            @selected = -1
                            @transition(EV_GOT_RESULTS) )
        else
            @transition(EV_CLEAR_RESULTS)

    searchBarKeyHandler: (event) =>
        prevent = true
        if event.which == 40 # down
            if @selected == -1 and @suggestionNum > 0
                @select(0)
            else if @selected >= 0
                @select((@selected+1) % @suggestionNum)
        else if event.which == 38 #up
            if @selected >= 0
                @select((@selected+@suggestionNum-1) % @suggestionNum)
        else if event.which == 9 # tab
            if @selected == -1 and @suggestionNum > 0
                @select(0)
        else if event.which == 13 # enter
            if @selected != -1
                @selectionHandler(event)
        else if event.which == 27 # esc
            @selected = -1
            @transition(EV_CLEAR_RESULTS)
            @transition(EV_CLOSE_DROPDOWN)
        else
            prevent = false
        if prevent then event.preventDefault()

    itemSelectedHandler: (event) ->
        data = $(event.currentTarget).data()
        @goToData(data)
        event.preventDefault()

    selectionHandler: (event) =>
        data = @selectedItem.data()
        @goToData(data)
        event.preventDefault()

    goToData: (datum) =>
         window.location.hash = window.linkToBudget(datum.code,window.pageModel.get('year'))
         window.location.reload()

    select: (selected) ->
        console.log 'selected',selected, @suggestions[selected].code
        suggestions = @$el.find('.search-results .search-dropdown-item')
        suggestions.toggleClass('selected',false)
        @selectedItem = $(suggestions.get(selected))
        @selectedItem.toggleClass('selected',true)
        @selectedItem[0].scrollIntoView(false)
        @selected = selected
        @partition.selectCode( @suggestions[selected].code )

    url: (query,limit) ->
        "#{window.pageModel.get('baseURL')}/api/search/budget?q=#{query}&limit=#{limit}"

    initialize: () ->
        @state = STATE_IDLE
        @suggestionNum = 0
        @suggestions = []
        url = @url("%QUERY",20)
        dataType = window.pageModel.get('dataType')
        @engine = new Bloodhound
                        name: 'budgets'
                        prefetch:
                            url: @url('משרד', 100)
                            ajax:
                                dataType: dataType
                        remote:
                            url: url
                            ajax:
                                dataType: dataType
                        dupDetector: (x,y) -> x.code==y.code && x.year==y.year
                        limit: 20
                        datumTokenizer: (d) -> Bloodhound.tokenizers.whitespace(d.title)
                        queryTokenizer: Bloodhound.tokenizers.whitespace
        @engine.initialize()
        @partition = new BudgetPartitionLayoutView(el: @$el.find('.search-partition-layout'))
        @dropdown = @$el.find("#search-dropdown")

$( ->
    console.log 'setting up searchbar'
    window.search = new SearchBar(el: $("#search-widget"))
)
