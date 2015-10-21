define [], () ->

  # window.onresize can only hold 1 callback, the ResizeNotifier will serve as
  # an initiator for onresize events
  class ResizeNotifier
      constructor: ->
          @resizeTimer    = 0
          @callbackQueue  = []

          window.onresize = (event) =>
              clearTimeout(@resizeTimer)
              @resizeTimer = setTimeout ( =>
                for callback in @callbackQueue
                  callback()
              ), 100

      registerResizeCallback: (callback) ->
          @callbackQueue.push(callback)

  return ResizeNotifier
