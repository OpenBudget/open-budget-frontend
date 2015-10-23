define ['backbone'], (Backbone) ->

  class DaysLimit extends Backbone.Model
      defaults:
          value: "1"

  return DaysLimit
