define ['backbone'], (Backbone) ->
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

      initialize: (options) ->
              @pageModel = options.pageModel
              dateStr = @get 'date'
              if dateStr?
                  @setTimestamp()
              else
                  @on 'change:date', =>
                      @setTimestamp()
              @set("uniqueId", "change-group-"+@get("group_id"))

      setTimestamp: ->
              @set 'timestamp', dateToTimestamp(@get 'date')

      getCodeChanges: (code) =>
              year = pageModel.get('year')
              key = "#{year}/#{code}"
              changes = _.filter(@get('changes'),(c)->_.indexOf(c['equiv_code'],key)>-1)
              d3.sum(changes, (c)->c['expense_change'])

      getDateType: () =>
              if @get('pending') then "pending" else "approved"

      doFetch: ->
              @fetch(dataType: @pageModel.get('dataType'))

      url: ->
              "#{pageModel.get('baseURL')}/api/changegroup/#{pageModel.get('changeGroupId')}/#{pageModel.get('year')}"


  return ChangeGroup
