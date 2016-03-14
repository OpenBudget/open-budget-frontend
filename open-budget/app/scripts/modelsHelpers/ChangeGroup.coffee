define ['backbone', 'underscore', 'scripts/appConfig'], (Backbone, _, appConfig) ->
  class ChangeGroup extends Backbone.Model

      defaults:
              req_titles: []
              transfer_ids: []
              committee_ids: []
              budget_codes: []
              prefixes: []
              year: null
              date: null
              group_id: null
              changes: []
              pending: false
              uniqueId: null

      initialize: (attrs, options) ->
              @options = options;

              dateStr = @get 'date'
              if dateStr?
                  @setTimestamp()
              else
                  @on 'change:date', =>
                      @setTimestamp()
              @set("uniqueId", "change-group-"+@get("group_id"))

      setTimestamp: ->
              timestamp = dateToTimestamp(@get 'date')
              @set 'timestamp', timestamp

      getCodeChanges: (code) =>
              year = @options.budgetYear
              key = "#{year}/#{code}"
              changes = _.filter(@get('changes'),(c)->_.indexOf(c['equiv_code'],key)>-1)
              d3.sum(changes, (c)->c['expense_change'])

      getDateType: () =>
              if @get('pending') then "pending" else "approved"

      fetch: ->
              super(dataType: appConfig.dataType)

      url: ->
              "#{appConfig.baseURL}/api/changegroup/#{@options.changeGroupId}/#{@options.budgetYear}"


  return ChangeGroup
