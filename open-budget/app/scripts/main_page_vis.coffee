class MainPageVis extends Backbone.View

    initialize: ->
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

        prefixes = {}
        models = []
        for model in @model.models
            if model.get('code').substring(0,4)=="0000"
                continue
            models.push model
            prefixes[model.get('code').substring(2,4)] = true
        prefixes = _.keys(prefixes)
        prefixes.sort (a,b) -> parseInt(a) - parseInt(b)
        centers = {}
        _.each( prefixes, (el,i) -> centers[el] = { x: i%9 * 100 + 200, y: Math.floor(i/9) * 75 + 150 })
        console.log prefixes.length

        @data = []
        that = this
        for model in models
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
                        { x: 600, y:300 }
            @data.push node


    render: ->
        @chart = new BubbleChart( el: @el, data: @data )
        @chart.render()
        @chart.start()

$( ->
    console.log "main_page"
    window.mainPageVis = new MainPageVis({el: $("#bubble-chart"), model: window.pageModel.budgetItems });
)
