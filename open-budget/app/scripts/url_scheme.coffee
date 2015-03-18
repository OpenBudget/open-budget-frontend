class URLSchemeHandler
        @DEFAULT_HOME = "#main//2014/main"

        constructor: ->
            @oldHash = window.location.hash
            @callbackList = []
            @reload = true

            @parseLink()

            window.onhashchange = @handleSchemeChange

        linkToBudget: (code,year) ->
            @linkParameters['type'] = 'budget'
            @linkParameters['code'] = code
            @linkParameters['year'] = year
            @buildLink()

        linkToTransfer: (code,year) ->
            @linkParameters['type'] = 'transfer'
            @linkParameters['code'] = code
            @linkParameters['year'] = year
            @buildLink()

        linkToEntity: (entityId) ->
            @linkParameters['type'] = 'entity'
            @buildLink()

        addAttribute: (key, value, reload) ->
            @linkParameters['attributes'][key] = value
            @reload = reload || false
            window.location.hash = @buildLink()

        getAttribute: (key) ->
            @linkParameters['attributes'][key]

        buildLink: () ->
            link = ""
            switch @linkParameters['type']
                when 'budget' then link = "#budget/#{@linkParameters['code'].slice(2)}/#{@linkParameters['year']}/#{window.pageModel.get('flow')}"
                when 'transfer' then link = "#transfer/#{@linkParameters['code']}/#{@linkParameters['year']}/#{window.pageModel.get('flow')}"
                when 'entity' then link = "#entity/#{@linkParameters['entityId']}/#{pageModel.get('year')}/#{pageModel.get('flow')}"

            if Object.keys(@linkParameters['attributes']).length > 0
                link += "?"+$.param(@linkParameters['attributes'])

            return link

        parseLink: () ->
            @linkParameters = {
                attributes: {}
            }

            hash = window.location.hash.substring(1)
            [hashPath, attributeString] = hash.split("?")
            [kind, identifier, year, flow] = hashPath.split("/",4)
            year = parseInt(year)

            console.log "hash:", kind, identifier, year, flow

            @linkParameters['kind'] = kind
            switch @linkParameters['kind']
                when 'budget', \
                     'transfer', \
                     'main'
                    @linkParameters['code'] = identifier
                when 'entity'
                    @linkParameters['entityId'] = identifier

            @linkParameters['year'] = year
            @linkParameters['flow'] = flow
            if attributeString && attributeString.length > 0
                @linkParameters['attributes'] = JSON.parse('{"' + decodeURI(attributeString.replace(/&/g, "\",\"").replace(/\=/g,"\":\"")) + '"}')

            @linkParameters


        onSchemeChange: (callback) ->
            @influencerList.push(callback)

        handleSchemeChange: =>
            for callback in @callbackList
                @reload &= callback(@oldHash, window.location.hash)

            if @reload
                window.location.reload()

            @oldHash = window.location.hash
            @reload = true

window.URLSchemeHandlerInstance = new URLSchemeHandler()
