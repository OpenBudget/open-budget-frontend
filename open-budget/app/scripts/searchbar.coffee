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
                       .offset((d) => [50,1])
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
                        .style('fill','rgba(0,0,0,0.2)')
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
        @upbacker.append('rect')
                 .attr('class','upbacker-bg')
                 .attr('x',-50)
                 .attr('width',50)
                 .attr('fill','rgba(0,0,0,0.2)')
        @upbacker.append('g')
                 .attr('class','upbacker-icon')
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
                return
            @change_tip.show(d)
            if d.c.length > 6
                @expandor.style('visibility','hidden')
            else
                @expandor.attr("transform", "translate(" + (@x(d.y+d.dy)+1) + "," + (@y(d.x)+1) + ")" )
                        .style('visibility','visible')
                        .attr("class","expandor #{ @cls(d) }")
                @expandor.select('rect')
                         .attr("width", 50)
                         .attr("height", d3.max([0,@y(d.dx) - @y(0)-2]))
                @expandor.select('g.icon')
                         .attr('transform', "translate("+0+","+(@y(d.dx/2) - @y(0))+")")
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
            @highlightor.style("visibility","hidden")
            $(".search-bar-tip").toggleClass('active',false)

        @cls = (d,suffix="") => window.changeClass( d.value, d.value*(d.o+100)/100.0 ) + suffix

        onSuccess = (root) =>
            if root
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
        window.location.hash = pageModel.URLSchemeHandlerInstance.linkToBudget(code,window.pageModel.get('year'))


    updateChart: (transition=false) =>
        if not @root
            return

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
        #g.on('mouseout', (d) => @hide_tip())

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

        if @root.c != '00'
            @upbacker.attr("transform", "translate(" + @w + "," + @y(@root.x) + ")" )
                    .style('visibility','visible')
                    .attr("class","upbacker #{ @cls(@root) }")
            @upbacker.select('.upbacker-bg')
                     .attr('height', @y(@root.dx) - @y(0))
            @upbacker.select('.upbacker-icon')
                     .attr('transform', "translate(0," + (@y(@root.dx/2)-@y(0)) + ")")
        else
            @upbacker.style('visibility','hidden')

    nodeForCode: (code) =>
        d = null
        console.log 'nodeForCode',code,d
        while code != '' and not d?
            d = @codes[code]
            console.log 'nodeForCode',code,d
            if not d?
                code = code.slice(0,-2)
        d

    selectCode: (code, transition) =>
        if not transition?
            transition = false
        node = @nodeForCode( code )
        root = @nodeForCode( code.slice(0,6) )

        if root?
            console.log 'root:',root,code.slice(0,6)
            @root = root
            @updateChart(transition)
        if node?
            console.log 'node:',node,code
            d3.event = { target: $("g[data-code=#{code}]")[0] }
            @show_tip(node)

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
        "mouseover .search-dropdown-item": "searchItemHover"

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
        i = 0
        for suggestion in @suggestions
            if suggestion?
                suggestion.index = i
                i+=1
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

    searchItemHover: (event) =>
        el = event.target
        index = $(el).attr('data-index')
        index = parseInt(index)
        @select(index)

    aggregateSuggestions: (rawSuggestionList) ->
        budgetCodes = {}
        suggestionList = []
        for s in rawSuggestionList
            if s.type == "Entity"
                # Nothing to do for entities
                suggestionList.push(s)
            else if s.type == "BudgetLine"
                if not budgetCodes[s.code]
                    # place a marker
                    suggestionList.push(s.code)
                    # start a new aggregate for this code
                    budgetCodes[s.code] = s

                if s.year > budgetCodes[s.code].year
                    budgetCodes[s.code] = s

        for index, s of suggestionList
            if typeof s == "string"
                suggestionList[index] = budgetCodes[s]

        return suggestionList

    getSuggestions: (event) =>
        event.preventDefault()
        val = @$el.find('#search-item').val()
        console.log 'getSuggestions',val
        if val != ''
            @transition(EV_OPEN_DROPDOWN)
            @engine.get( val
                        ,
                         (suggestions) =>
                            @suggestions = @aggregateSuggestions(suggestions)
                            @suggestionNum = suggestions.length
                            @selected = -1
                            @transition(EV_GOT_RESULTS)
                            ga('send', 'event', 'searchbar', 'results', val, @suggestionNum) )
            ga('send', 'event', 'searchbar', 'search', val, 1);
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
        newHash = switch datum.type
            when 'BudgetLine' then pageModel.URLSchemeHandlerInstance.linkToBudget(datum.code, datum.year)
            when 'Entity' then pageModel.URLSchemeHandlerInstance.linkToEntity(datum.id)
            else null

        if newHash
            window.location.hash = newHash

    select: (selected) ->
        # Sanity check
        if @suggestions[selected] == undefined
          return

        console.log 'selected',selected, @suggestions[selected].code
        suggestions = @$el.find('.search-results .search-dropdown-item')
        suggestions.toggleClass('selected',false)
        @selectedItem = $(suggestions.get(selected))
        @selectedItem.toggleClass('selected',true)
        @selectedItem[0].scrollIntoView(false)
        @selected = selected
        if (@suggestions[selected].type == "BudgetLine")
            @partition.selectCode( @suggestions[selected].code )

    url: (query,limit) ->
        "#{window.pageModel.get('baseURL')}/api/search/full_text?q=#{query}&limit=#{limit}"

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
                        dupDetector: (x,y) ->
                            return switch
                                when x.type == 'BudgetLine' then x.type==y.type && x.code==y.code && x.year==y.year
                                when x.type == 'Entity' then x.type==y.type && x.name==y.name && x.id==y.id
                                else false
                        limit: 20
                        datumTokenizer: (d) ->
                            return switch
                                when d.type == 'BudgetLine' then Bloodhound.tokenizers.whitespace(d.title)
                                when d.type == 'Entity' then Bloodhound.tokenizers.whitespace(d.name)
                                else ""
                        queryTokenizer: Bloodhound.tokenizers.whitespace
        @engine.initialize()
        @partition = new BudgetPartitionLayoutView(el: @$el.find('.search-partition-layout'))
        @dropdown = @$el.find("#search-dropdown")

$( ->
    console.log 'setting up searchbar'
    window.search = new SearchBar(el: $("#search-widget"))
)
