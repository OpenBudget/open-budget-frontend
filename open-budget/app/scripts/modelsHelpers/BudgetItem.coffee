define ['backbone'], (Backbone) ->
  class BudgetItem extends Backbone.Model

      defaults:
              net_allocated: null
              code: null
              gross_allocated: null
              title: null
              gross_revised: null
              gross_used: null
              depth: null
              net_revised: null
              year: null
              net_used: null
              explanation: null
              analysis_short_term_yearly_change: null
              orig_codes: [],
              uniqueId: null

      initialize: (options) ->
          @pageModel = options.pageModel
          @set("uniqueId", "budget-item-" + @get("code") + "-" + @get("year"))

      do_fetch: ->
          @fetch(dataType: @pageModel.get('dataType'), reset: true)

      get_class: ->
          window.changeClass( @get('net_allocated'), @get('net_revised') )

      url: ->
          "#{pageModel.get('baseURL')}/api/budget/#{@get('code')}/#{@get('year')}"

  return BudgetItem;
