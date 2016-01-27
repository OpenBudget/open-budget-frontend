define ['backbone'], (Backbone) ->
  class SupportLine extends Backbone.Model

      initialize: (attrs, options) ->
        @pageModel = options.pageModel

      defaults:
          kind: null
          code: null
          title: null
          amount_allocated: null
          amount_supported: null
          num_used: 1
          company_id: null
          ngo_id: null
          year: null
          recipient: null
          subject: null

      toLocaleJSON: (requestedLocale) ->
        locale = requestedLocale || "he"
        baseJSON = @toJSON()
        resultJSON = {}
        for key, value of baseJSON
          normalizedKey = @pageModel.supportFieldNormalizer.normalize(key, locale)
          if normalizedKey?
            resultJSON[normalizedKey] = value

        return resultJSON

  return SupportLine
