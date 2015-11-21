define ['backbone', 'vendor/moment'], (Backbone, moment) ->
  class SpendingLine extends Backbone.Model

    defaults:
      entity_id: null
      budget_code: null
      supplier_id: null
      decision: null
      regulation: null
      subjects: []
      supplier: null
      start_date: null
      entity_kind: null
      description: null
      end_date: null
      volume: 0
      reason: null
      documents: [ ]
      contact_email: null
      last_update_date: null
      publisher: null
      url: null
      claim_date: null
      publication_id: null
      contact: null
      history: [ ]

    parse: (response)->
      # "20/11/2015"
      response.last_update_date = moment(response.last_update_date, "D/M/YYYY").toDate()

      if response.claim_date
        # "20/11/2015"
        response.claim_date = moment(response.claim_date, "D/M/YYYY").toDate()

      # "2015-11-21T13:11:14.256340"
      response.last_modified = moment(response.last_modified, "YYYY-MM-DDTHH:mm:ss.SSSS").toDate()

      # "05/11/2015"
      response.start_date = if response.start_date then moment(response.start_date, "D/M/YYYY").toDate() else null

      # "31/12/2015"
      response.end_date = if response.end_date then moment(response.end_date, "D/M/YYYY").toDate() else null

      response

  return SpendingLine
