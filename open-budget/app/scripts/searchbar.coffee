class BudgetPartitionLayoutView extends Backbone.View

    initialize: ->
        @render()
        @codes = {}

    render: ->

        @vis = d3.select(@el)
                .append("svg:svg")
        @partition = d3.layout.partition()
                            .value((d) -> d.size) #net_allocated)

        @cls = (d) => window.changeClass( d.orig_size, d.value ) + "_bg"

        onSuccess = (root) =>

            @root = root.value
            @data = @partition.nodes(@root)

            @codes = {}
            for datum in @data
                @codes[datum.code] = datum

            @updateChart()

        $.ajax(
            dataType: window.pageModel.get('dataType')
            url: "#{window.pageModel.get('baseURL')}/api/sysprop/static-budget"
            success: onSuccess
        )

    updateChart: () =>
        console.log "PL","updateChart"
        @w = @$el.width()-15
        @h = 400 # @$el.height()

        console.log "PL","updateChart #{@w} x #{@h}"

        @$el.find('svg')
            .attr('width', @w)
            .attr('height', @h)

        @x = d3.scale.linear().domain([@root.y+@root.dy/2,@root.y+@root.dy*3]).range([@w, 0])
        @y = d3.scale.linear().domain([@root.x,@root.x+@root.dx]).range([0, @h])

        transform = (d) => "translate(" + (-8 - @x(d.dy) + @x(0) ) +  "," + (@y(d.dx / 2) - @y(0)) + ")"

        _data = _.filter(@data, (d) => d.depth - @root.depth < 3)
        g_all = @vis.selectAll("g").data(_data, (d)->d.code)
        g = g_all.enter().append("svg:g")
                # .on("click", click)
        g.attr("class", @cls )
         .attr("data-code", (d) -> d.code)

        g.append("svg:rect")
            .attr("class", (d) -> if d.children? then "parent" else "child")
            .on("click", (d) => if d.children? then @selectCode(d.code) )

        g.append("svg:text")
            .attr("dy", ".35em")
            .text((d) -> d.name)

        g_all.exit().remove()

        t = g_all.transition()
             .duration(750)
             .attr("transform", (d) => "translate(" + @x(d.y+d.dy) + "," + @y(d.x) + ")" )
        t.select("rect")
            .attr("width", Math.abs(@x(@root.dy) - @x(0)))
            .attr("height", (d) => @y(d.dx) - @y(0))
        t.select("text")
            .attr("transform", transform)
            .attr("dx", (d) => if d.y == @root.y then @x(@root.dy/2) - @x(0) else 0)
            .attr("class", (d) => if @y(d.dx) - @y(0) > 12 then "big-title" else "small-title")

            # d3.select(@el) # window
            #     .on("click", () -> click(root))

    selectCode: (code) =>
        d = null
        code = code.slice(0,6)
        console.log "CCC", code
        while not d?
            d = @codes[code]
            if not d?
                code = code.slice(0,-2)

        if d?
            console.log d
            @root = d
            @updateChart()

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
        "#{window.pageModel.get('baseURL')}/api/search/budget/#{pageModel.get('year')}?q=#{query}&limit=#{limit}"

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
