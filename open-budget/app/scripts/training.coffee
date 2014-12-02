class TrainingStep extends Backbone.Model
    defaults:
        title: null
        content: null
        path: null
        element: null
        orphan: null
        placement: null
        duration: null
        backdrop: null

class TrainingSteps extends Backbone.Collection
    model: TrainingStep

    initialize: (models) ->
        @fetch(dataType: window.pageModel.get('dataType'), reset: true)

    url: ->
        "#{window.pageModel.get('baseURL')}/api/training/#{window.pageModel.get('flow')}"


class TrainingView extends Backbone.View

    initialize: ->
        if not @checkStorage('localStorage')
            # Disable the tour if window.localStorage isn't available.
            # Bootstrap Tour requires localStorage to function properly in
            # multi-page tours and to identify first visits to the page.
            $(@el).hide()
            return

        window.pageModel.on 'ready-budget-bubbles', => @loadTour()
        window.pageModel.on 'ready-budget-history', => @loadTour()
        window.pageModel.on 'ready-changegroup', => @loadTour()

    events:
        "click": "onTrainingButtonClick"

    loadTour: ->
        console.log "loadTour", window.pageModel.get('flow')
        @steps = new TrainingSteps([])
        @steps.on 'reset', => @initTour(_.map(@steps.models, (i)->i.toJSON()))

    initTour: (steps) ->
        console.log "got #{steps.length} steps"

        for step in steps
            @replaceNullWithUndefined(step)

        # Check the URL parameters for special options.
        params = @searchStringToParamArray(document.location.search)
        forceTour = 'forceTour=1' in params
        isRedirected = 'redirect=1' in params

        # The first step is intended for redirected users. Skip it if not redirected.
        # TODO: Does this make sense in flows other than 'main'?
        # TODO: Not a perfect solution, the 'previous' button is enabled on the first step.
        if not isRedirected
            console.log "tour: not redirected, disabling first step"
            # Make Bootstrap Tour skip the step by making it non-orphan with no element.
            steps[0].element = ''
            steps[0].orphan = false

        tour = new Tour(
            name: "tour-#{window.pageModel.get('flow')}"
            steps: steps
            keyboard: false # Disabled since the buttons are hard-coded to ltr.
            basePath: document.location.pathname
            backdrop: true
            backdropPadding: 5
            template: JST.tour_dialog()
            debug: true
            onEnd: (tour) =>
                params = @searchStringToParamArray(document.location.search)
                if 'forceTour=1' in params
                    # Redirect to the current page, but without the forceTour parameter.
                    # This gets rid of forceTour to prevent it from persisting and causing
                    # unexpected starting of the tour upon moving to another page.
                    params = @filterArray(params, 'forceTour=1')
                    newSearch = @paramArrayToSearchString(params)
                    newUrl = [document.location.pathname, newSearch, document.location.hash].join('')
                    console.log 'Tour: Redirecting to #{newUrl}'
                    document.location.href = newUrl
        )
        @tour = tour

        console.log "initializing tour"
        # If we're in the middle of a multi-page tour, init() will automatically
        # start the tour.
        # Otherwise, if the tour was never shown, start() will start it.
        # start() has no effect if the tour is already displayed.
        tour.init()
        tour.start()

        if forceTour and not @isTourRunning(tour)
            console.log "forcing the tour"
            tour.restart()

    replaceNullWithUndefined: (obj) ->
        for own key, value of obj
            if value is null
                obj[key] = undefined

    onTrainingButtonClick: (event) ->
        event.preventDefault()
        # Don't start the tour if it wasn't initialized (due to loading failure)
        # or is already running.
        if (not @tour?) or @isTourRunning(@tour)
            return
        @tour.restart()

    checkStorage: (storageName) ->
        # Checks that the storage is enabled and writable.
        # The storage is passed by name since under Chrome even accessing
        # window.localStorage throws an exception if it's disabled .
        try
            storage = window[storageName]
            key = 'tour_storage_test'
            storage.setItem(key, 'test')
            storage.removeItem(key)
            return true
        catch
            return false

    isTourRunning: (tour) ->
        # Assumes that the tour is initialized.
        return not tour.ended() and tour.getCurrentStep() != null

    searchStringToParamArray: (searchStr) ->
        if searchStr.indexOf('?') == 0
            searchStr = searchStr.substr(1)
        return (s for s in searchStr.split('&') when s != '')

    paramArrayToSearchString: (params) ->
        if params.length > 0
            return '?' + params.join('&')
        else
            return ''

    filterArray: (array, value) ->
        return (item for item in array when item != value)


$( ->
        console.log "initializing the training view"
        window.trainingView = new TrainingView({el: $("#intro-link"), model: window.pageModel})
)
