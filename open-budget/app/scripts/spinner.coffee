class SpinnerView extends Backbone.View

    initialize: ->
        @render()

    render: ->
        @$el.html( window.JST.spinner() )

    hide: ->
        #@$el.css('display','none')

$( ->
    window.spinner = new SpinnerView(el: window.pageModel.article.find(".spinner-container"))
    window.pageModel.on 'ready', ->
        window.spinner.hide()
)
