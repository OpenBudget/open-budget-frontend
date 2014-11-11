class TrainingView extends Backbone.View

    initialize: ->
        @loadTour()

    events:
        "click": "onTrainingButtonClick"

    loadTour: ->
        url = "https://spreadsheets.google.com/feeds/list/1X_E0ut1bSG511lYJwsvFYjKonwqzVmkQNM0SCS2USnE/od6/public/values?alt=json-in-script&callback=?"
        $.getJSON(url, (data) =>
            steps = @sheet_to_steps(data)
            @initTour(steps)
        )
        .fail(() ->
            console.log("Error loading training steps from ${url}.")
        )

    initTour: (steps) ->
        tour = new Tour(
            steps: steps
            basePath: document.location.pathname
            backdrop: true
            backdropPadding: 5
            template: '<div class="popover" role="tooltip">
              <div class="arrow"></div>
              <h3 class="popover-title"></h3>
              <div class="popover-content"></div>
              <div class="popover-navigation">
                <div class="btn-group">
                  <button class="btn btn-sm btn-default" data-role="prev">&laquo; הקודם</button>
                  <button class="btn btn-sm btn-default" data-role="next">הבא &raquo;</button>
                  <button class="btn btn-sm btn-default"
                          data-role="pause-resume"
                          data-pause-text="Pause"
                          data-resume-text="Resume">Pause</button>
                </div>
                <button class="btn btn-sm btn-default" data-role="end">סיום</button>
              </div>
            </div>'
        )
        tour.init()
        @tour = tour
        return tour

    sheet_to_steps: (root) ->
        is_blank = (text) ->
            return text? and $.trim(text) == ''

        newline_to_br = (text) ->
            if text? then text.replace(/\n/g, "<br />") else undefined

        entry_to_step = (entry) ->
            # Rename 'gsx$<field>' keys to '<field>', ignore blank values.
            dict = {}
            for own key, value of entry
                if key.indexOf('gsx$') == 0
                    value = value.$t
                    dict[key[4..]] = if is_blank(value) then undefined else value

            if not dict.path?
                return null

            # Create the Bootstrap Tour step object.
            step =
                title: newline_to_br(dict.title)
                content: newline_to_br(dict.content)
                path: dict.path
                element: dict.elementselector
                orphan: if not dict.elementselector? then true else undefined
                placement: dict.tooltipplacement
                duration: if dict.durationms? then parseInt(dict.durationms, 10) else undefined
                backdrop: dict.disablebackdrop != 'true'

        entries = root.feed.entry
        steps = []
        for entry in entries
            step = entry_to_step(entry)
            steps.push(step) if step != null
        return steps

    onTrainingButtonClick: (event) ->
        event.preventDefault()
        if not @tour?
            # The tour wasn't initialized (due to loading failure).
            return
        @tour.restart()

$( ->
        console.log "initializing the training view"
        window.trainingView = new TrainingView({el: $("#intro-link"), model: window.pageModel})
)
