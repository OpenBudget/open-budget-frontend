define [], ->
  class URLSchemeHandler

          constructor: (defaultYear, defaultHome) ->
              @defaultYear = defaultYear
              @defaultHome = defaultHome
              @oldHash = window.location.hash
              @callbackList = []
              @reload = true

              @parseLink()




          linkToBudget: (code,year) ->
              parameters = $.extend(true, {}, @linkParameters)
              parameters['kind'] = 'budget'
              parameters['code'] = code.slice(2)
              parameters['year'] = year
              @buildLink(parameters)

          linkToTransfer: (code,year) ->
              parameters = $.extend(true, {}, @linkParameters)
              parameters['kind'] = 'transfer'
              parameters['code'] = code
              parameters['year'] = year
              @buildLink(parameters)

          linkToEntity: (entityId) ->
              parameters = $.extend(true, {}, @linkParameters)
              parameters['kind'] = 'entity'
              parameters['entityId'] = entityId
              @buildLink(parameters)

          linkToPublication: (entityId, publication) ->
              parameters = $.extend(true, {}, @linkParameters)
              parameters['kind'] = 'entity'
              parameters['entityId'] = entityId
              parameters['publication'] = publication
              @buildLink(parameters)

          linkToSpending: () ->
              parameters = $.extend(true, {}, @linkParameters)
              parameters['kind'] = 'spending'
              @buildLink(parameters)

          updateHash: (reload) ->
              newHash = @buildLink(@linkParameters)
              if newHash != window.location.hash
                  @reload = reload || false
                  window.location.hash = newHash

          addAttribute: (key, value, reload) ->
              @linkParameters['attributes'][key] = value
              @updateHash(reload)

          removeAttribute: (key, reload) ->
              delete @linkParameters['attributes'][key]
              @updateHash(reload)

          getAttribute: (key) ->
              @linkParameters['attributes'][key]

          buildLink: (parameters) ->
              link = ""
              switch parameters['kind']
                  when 'budget' then link = "#budget/#{parameters['code']}/#{parameters['year']}/#{parameters['flow']}"
                  when 'transfer' then link = "#transfer/#{parameters['code']}/#{parameters['year']}/#{parameters['flow']}"
                  when 'entity'
                    if parameters['publication']
                      link = "#entity/#{parameters['entityId']}/publication/#{parameters['publication']}"
                    else
                      link = "#entity/#{parameters['entityId']}/#{parameters['year']}/#{parameters['flow']}"
                  when 'main' then link = "#main//#{parameters['year']}/#{parameters['flow']}"
                  when 'spending' then link = "#spending//#{parameters['year']}/#{parameters['flow']}"

              if Object.keys(parameters['attributes']).length > 0
                  link += "?"+$.param(parameters['attributes'])

              return link

          parseLink: () ->
              @linkParameters = {
                  attributes: {}
              }

              hash = window.location.hash.substring(1)
              [hashPath, attributeString] = hash.split("?")
              [kind, identifier, year, flow] = hashPath.split("/",4)
              year = parseInt(year) || @defaultYear
              kind = kind || @defaultHome
              flow = flow || 'main'
              identifier = identifier || ''

              console.log "hash:", kind, identifier, year, flow

              @linkParameters['kind'] = kind
              switch @linkParameters['kind']
                  when 'budget', \
                       'transfer', \
                       'main'
                      if identifier.search("00") == 0
                          identifier = identifier.substring(2)
                      @linkParameters['code'] = identifier
                  when 'entity'
                      @linkParameters['entityId'] = identifier

              @linkParameters['year'] = year || new Date().getFullYear()
              @linkParameters['flow'] = flow
              if attributeString && attributeString.length > 0
                  @linkParameters['attributes'] = JSON.parse('{"' + decodeURI(attributeString.replace(/&/g, "\",\"").replace(/\=/g,"\":\"")) + '"}')

              @linkParameters


          onSchemeChange: (callback) ->
              @callbackList.push(callback)

          handleSchemeChange: =>
              console.log "handleSchemeChange "+@reload+" "+window.location.hash
              console.log "callbackList "+@callbackList
              for callback in @callbackList
                  @reload &= callback(@oldHash, window.location.hash)

              if @reload
                  window.location.reload()
              else
                  ga('send', 'pageview')

              @oldHash = window.location.hash
              @reload = true
              console.log "handleSchemeChange reload --> "+@reload


  URLSchemeHandler
