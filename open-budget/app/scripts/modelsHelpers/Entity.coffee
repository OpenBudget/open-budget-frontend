define ['backbone'], (Backbone) ->

  class Entity extends Backbone.Model

      defaults:
          kind: null
          name: null
          supports: []
          exemptions: []
          id: null
          exemptions_by_publisher: {}
          exemptions_sum: null

      initialize: (options) ->
          @entity_id = options.entityId
          @pageModel = options.pageModel

      doFetch: ->
              @fetch(dataType: @pageModel.get('dataType'), success: @handleFetchResult)

      url: =>
          "#{pageModel.get('baseURL')}/api/entity/#{@entity_id}"

      handleFetchResult: (collection, response) =>
          @supports = response.supports
          @exemptions = response.exemptions

          @set('exemptions_sum', @get_exemptions_total_volume())

          @exemptionsByPublisher()

          @trigger('ready')

      get_exemptions_total_volume: =>
          exemptions_sum = 0
          if @exemptions?
              for exemption in @exemptions
                  exemptions_sum += exemption.volume
          return exemptions_sum

      exemptionsByPublisher: =>
          exemptions_by_publisher = {}
          if @exemptions?
              for exemption in @exemptions
                  if not exemptions_by_publisher[exemption.publisher]?
                      exemptions_by_publisher[exemption.publisher] = {publisher: exemption.publisher, exemptions: [], total_volume: 0}
                  exemptions_by_publisher[exemption.publisher].exemptions.splice(0, 0, exemption)
                  exemptions_by_publisher[exemption.publisher].total_volume += exemption.volume
                  exemptions_by_publisher[exemption.publisher].start_date = @min_date(exemptions_by_publisher[exemption.publisher].start_date, @convert_str_to_date(exemption.start_date))
                  exemptions_by_publisher[exemption.publisher].end_date = @max_date(exemptions_by_publisher[exemption.publisher].end_date, @convert_str_to_date(exemption.end_date))

          for publisher of exemptions_by_publisher
              if (exemptions_by_publisher.hasOwnProperty(publisher))
                  exemptions_by_publisher[publisher].start_date = @convert_date_to_str(exemptions_by_publisher[publisher].start_date)
                  exemptions_by_publisher[publisher].end_date = @convert_date_to_str(exemptions_by_publisher[publisher].end_date)

          exemptions_by_publisher


      convert_str_to_date: (date_str) ->
          if date_str?
              date_arr = date_str.split("/")
              return new Date(date_arr[2], parseInt(date_arr[1]) - 1, date_arr[0])
          return null

      convert_date_to_str: (d) ->
          if d?
              "" + d.getDate() + "/" + (d.getMonth() + 1) + "/" + d.getFullYear()
          else
              ""

      min_date: (a,b) ->
          if not a?
              return b
          if not b?
              return a
          if a.getTime() < b.getTime()
              return a
          return b

      max_date: (a,b) ->
          if not a?
              return b
          if not b?
              return a
          if a.getTime() < b.getTime()
              return b
          return a

  return Entity
