class BudgetPartitionLayoutView extends Backbone.View

    initialize: ->
        @render()

    render: ->
        @w = @$el.width()-15
        @h = 400 # @$el.height()

        @vis = d3.select(@el)
                .append("svg:svg")
                    .attr("width", @w)
                    .attr("height", @h);
        @partition = d3.layout.partition()
                            .value((d) -> d.size) #net_allocated)

        d3.json("/static-budget.json", (root) =>

            data = @partition.nodes(root)

            @x = d3.scale.linear().domain([root.dy,1]).range([@w, 0])
            @y = d3.scale.linear().range([0, @h])

            g = @vis.selectAll("g").data(data)
                    .enter().append("svg:g")
                    .attr("transform", (d) => "translate(" + @x(d.y+d.dy) + "," + @y(d.x) + ")" )
                    # .on("click", click)

            transform = (d) => "translate(" + (-8 - @x(d.dy) + @x(0) ) +  "," + (@y(d.dx / 2) - @y(0)) + ")"

            g.append("svg:rect")
                .attr("width", Math.abs(@x(root.dy) - @x(0)))
                .attr("height", (d) => @y(d.dx) - @y(0))
                .attr("class", (d) -> if d.children? then "parent" else "child")

            g.append("svg:text")
                .attr("transform", transform)
                .attr("dy", ".35em")
                .style("opacity", (d) -> d.dx * @h > 12 ? 1 : 0)
                .text((d) -> d.name)
        )

            # d3.select(@el) # window
            #     .on("click", () -> click(root))

  # function click(d) {
  #   if (!d.children) return;
  #
  #   kx = (d.y ? w - 40 : w) / (1 - d.y);
  #   ky = h / d.dx;
  #   x.domain([d.y, 1]).range([d.y ? 40 : 0, w]);
  #   y.domain([d.x, d.x + d.dx]);
  #
  #   var t = g.transition()
  #       .duration(d3.event.altKey ? 7500 : 750)
  #       .attr("transform", function(d) { return "translate(" + x(d.y) + "," + y(d.x) + ")"; });
  #
  #   t.select("rect")
  #       .attr("width", d.dy * kx)
  #       .attr("height", function(d) { return d.dx * ky; });
  #
  #   t.select("text")
  #       .attr("transform", transform)
  #       .style("opacity", function(d) { return d.dx * ky > 12 ? 1 : 0; });
  #
  #   d3.event.stopPropagation();
  # }


class SearchBar extends Backbone.View

    events:
        "submit form": "selectionHandler"
        "click #btn-tree": "toggleOpen"
        "click #search-item": "headerClick"
        "input #search-item": "getSuggestions"
        "keydown #search-item": "searchBarKeyHandler"
        "click .search-dropdown-item": "itemSelectedHandler"

    isActive: () =>
        @dropdown.hasClass('active')

    toggleOpen: =>
        if !@isActive()
            setTimeout( () =>
                         if @isActive()
                            @$el.find('.search-partition-layout svg').css('display','inherit')
                       ,
                        500
                      )
        else
            @$el.find('.search-partition-layout svg').css('display','none')
        @dropdown.toggleClass('active')

    headerClick: (event) =>
        event.preventDefault()
        @$el.find("#search-dropdown").toggleClass('active',true)
        if !@isActive()
            setTimeout( () =>
                         if @isActive()
                            @$el.find('.search-partition-layout svg').css('display','inherit')
                       ,
                        500
                      )

    getSuggestions: (event) =>
        event.preventDefault()
        val = @$el.find('#search-item').val()
        console.log 'getSuggestions',val
        @engine.get( val, (suggestions) => @renderSuggestions(suggestions) )

    renderSuggestions: (suggestions) =>
        @suggestions = suggestions.length
        @selected = -1
        sr = @$el.find('.search-results')
        sr.html('')
        console.log 'renderSuggestions',suggestions
        for suggestion in suggestions
            item = $(JST.search_dropdown_item(suggestion))
            sr.append(item)
            item.data(suggestion)

    searchBarKeyHandler: (event) =>
        prevent = true
        if event.which == 40
            if @selected == -1 and @suggestions > 0 # down
                @select(0)
            else if @selected >= 0
                @select((@selected+1) % @suggestions)
        else if event.which == 38 #up
            if @selected >= 0
                @select((@selected+@suggestions-1) % @suggestions)
        else if event.which == 9
            if @selected == -1 and @suggestions > 0 # tab
                @select(0)
        else if event.which == 13
            if @selected != -1
                @selectionHandler(event)
        else
            prevent = false
        if prevent then event.preventDefault()

    itemSelectedHandler: (event) ->
        data = $(event.currentTarget).data()
        console.log event, data
        @goToData(data)
        event.preventDefault()

    selectionHandler: (event) =>
        data = @selectedItem.data()
        console.log data
        @goToData(data)
        event.preventDefault()

    goToData: (datum) =>
         window.location.hash = window.linkToBudget(datum.code,window.pageModel.get('year'))
         window.location.reload()

    select: (selected) ->
        console.log 'select',selected
        suggestions = @$el.find('.search-results .search-dropdown-item')
        suggestions.toggleClass('selected',false)
        @selectedItem = $(suggestions.get(selected))
        @selectedItem.toggleClass('selected',true)
        @selected = selected

    url: (query,limit) ->
        "#{window.pageModel.get('baseURL')}/api/search/budget/#{pageModel.get('year')}?q=#{query}&limit=#{limit}"

    initialize: () ->
        url = @url("%QUERY",20)
        dataType = window.pageModel.get('dataType')
        console.log 'url:', url
        console.log 'dataType:', dataType
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
        @suggestions = 0
        @partition = new BudgetPartitionLayoutView(el: @$el.find('.search-partition-layout'))
        @dropdown = @$el.find("#search-dropdown")
        console.log "DROPDOWN=",@dropdown

$( ->
    console.log 'setting up searchbar'
    window.search = new SearchBar(el: $("#search-widget"))
)

# $("#search-item").typeahead(
#         name: 'budgets'
#         limit: 20
#         engine: { compile: (x) -> { render: JST[x]} }
#
#         template: 'search_dropdown_item'
#         footer: '<div class="tt-search-footer"></div>'
#
#         remote:
#                 url: window.pageModel.get('baseURL')+"/api/search/budget/#{pageModel.get('year')}?q=%QUERY&limit=20"
#                 dataType: 'jsonp'
#                 cache: true
#                 timeout: 3600
#                 filter: (l) ->
#                         for x in l
#                                 x._code = x.code.substring(2)
#                                 x.value = x._code
#                         l
# )
# $('.typeahead.input-sm').siblings('input.tt-hint').addClass('hint-small');
# $('.typeahead.input-lg').siblings('input.tt-hint').addClass('hint-large');
# $("#search-item").bind('typeahead:selected', get_program )
# $("#search-item").bind('change', get_program )
# $("#search-form").submit( ->
#         false
#         )


# get_program = (obj,datum,name) ->
#         console.log "selected:", obj, datum, name
#         console.log "selected2:", $("#search-item").val()
#         if datum?
#             code = datum.code
#             window.location.hash = "#budget/" + code + "/" + window.pageModel.get('year')
#             window.location.reload()
#         else
#             code = $("#search-item").val()
#             if code.match(/^[0-9]+$/)
#                 window.location.hash = "#budget/00" + code + "/" + window.pageModel.get('year')
#                 window.location.reload()