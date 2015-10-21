define ['backbone'], (Backbone) ->
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

  return SpendingLine
