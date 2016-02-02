define ['backbone'], (Backbone) ->

  class Participant extends Backbone.Model

      defaults:
              kind: ""
              name: null
              party: null
              photo_url: "data:image/svg+xml;charset=utf-8;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0Ij4NCiAgICA8cGF0aCBkPSJNMTIgMmMtNS41MiAwLTEwIDQuNDgtMTAgMTBzNC40OCAxMCAxMCAxMCAxMC00LjQ4IDEwLTEwLTQuNDgtMTAtMTAtMTB6bTAgM2MxLjY2IDAgMyAxLjM0IDMgM3MtMS4zNCAzLTMgMy0zLTEuMzQtMy0zIDEuMzQtMyAzLTN6bTAgMTQuMmMtMi41IDAtNC43MS0xLjI4LTYtMy4yMi4wMy0xLjk5IDQtMy4wOCA2LTMuMDggMS45OSAwIDUuOTcgMS4wOSA2IDMuMDgtMS4yOSAxLjk0LTMuNSAzLjIyLTYgMy4yMnoiLz4NCiAgICA8cGF0aCBkPSJNMCAwaDI0djI0aC0yNHoiIGZpbGw9Im5vbmUiLz4NCjwvc3ZnPg=="
              start_date: null
              end_date: null
              title: null
              start_timestamp: null
              end_timestamp: null
              unique_id: null

      setTimestamps: (maxTime) ->
          @set 'start_timestamp', dateToTimestamp(@get 'start_date')
          if (@get 'end_date')?
              @set 'end_timestamp', dateToTimestamp(@get 'end_date')
          else
              @set 'end_timestamp', maxTime

          @set('unique_id', @get('title')+"-"+"-"+@get('start_timestamp')+"-"+@get('end_timestamp'))

  return Participant
