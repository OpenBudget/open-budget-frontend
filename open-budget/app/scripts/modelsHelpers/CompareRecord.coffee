define [], () ->
  class CompareRecord extends Backbone.Model
    defaults:
        code: null
        title: null
        orig_2014: null
        orig_2015: null
        rev_2014: null
        rev_2015: null
        group_top: null
        grouo_full: null
        year: 2014

  return CompareRecord
