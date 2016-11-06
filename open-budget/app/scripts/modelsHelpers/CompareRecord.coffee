define(['backbone'], (Backbone) ->
  class CompareRecord extends Backbone.Model
    defaults:
        code: null
        prev_code: null
        title: null
        orig_2016: null
        orig_2017: null
        rev_2016: null
        rev_2017: null
        group_top: null
        group_full: null
        year: 2017

  return CompareRecord
)
