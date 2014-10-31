class MainPageVis extends Backbone.View

    initialize: ->
        if @model?
            @model.on 'reset', =>
                @prepareData()
                @render()
                @toggle = false

    events:
        'click': 'switchToggle'

    switchToggle: ->
        @toggle = !@toggle
        @chart.start()

    prepareData: ->
        fill_color = -> "#aabbcc"
        stroke_color = -> "#ccbbaa"
        tooltip_contets = -> (this.src.get('code').substring(2)) + ": " + (this.src.get('title'))

        parentItems = pageModel.budgetItems2.models
        console.log parentItems
        bySize = _.sortBy( parentItems, (x) -> -x.get('net_revised') )

        prefixes = []
        models = []
        for model in bySize
            digits = model.get('code').substring(2,4)
            if digits=="00"
                continue
            prefixes.push(digits)
        console.log prefixes

        centers = {}
        _.each( prefixes, (el,i) -> centers[el] = { x: i%6 * 150 + 200, y: Math.floor(i/6) * 150 + 250 })
        console.log prefixes.length

        @data = []
        that = this
        for model in pageModel.budgetItems4.models
            if model.get('code').substring(0,4)=="0000"
                continue

            value = model.get('net_allocated')
            revised = model.get('net_revised')
            if !(value>0) || !(revised>0)
                continue
            node =
                id: model.get('code')
                src: model
                value: value
                rev: revised
                part: revised / value
                className: -> changeClass(this.value,this.rev)+"_svg"
                fill_color: null
                stroke_color: null
                tooltip_contents: tooltip_contets
                center: ->
                    if that.toggle
                        centers[@.id.substring(2,4)]
                    else
                        { x: 600, y:400 }
            @data.push node


    render: ->
        @chart = new BubbleChart( el: @el, data: @data, numParts: -> if @toggle then 63 else 1 )
        @chart.render()
        @chart.start()

$( ->
    console.log "main_page"
    window.mainPageVis = new MainPageVis({el: $("#bubble-chart"), model: window.pageModel.budgetItems4 });
)
