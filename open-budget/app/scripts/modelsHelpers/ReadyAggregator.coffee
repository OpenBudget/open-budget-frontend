define [], () ->

  class ReadyAggregator

      constructor: (event) ->
          @readyCounter = 0
          @collections = []
          @models = []
          @event = event
          @ready = false

      addModel: (model) ->
          @models.push model
          @readyCounter += 1
          model.on 'change',() => @checkIfReady()
          @

      addCollection: (collection) ->
          @collections.push collection
          @readyCounter += 1
          console.log "addCollection: "+@event+"="+@readyCounter
          collection.on 'reset',() => @checkIfReady()
          @

      checkIfReady: (callback) ->
          if !@ready
              @readyCounter -= 1

          if callback?
              @callback = callback

          console.log "checkIfReady: "+@event+"="+@readyCounter
          if @readyCounter == 0
              @ready = true
              pageModel.trigger(@event)
              pageModel.set 'event-triggered-' + @event, true
              if @callback then @callback()

  return ReadyAggregator
