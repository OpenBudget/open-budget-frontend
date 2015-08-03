define ['backbone', 'main_page_tabs', 'url_scheme'], (Backbone) ->
    dateToTimestamp = (date) ->
        if !date? then return null
        date = date.split('/')
        date = new Date(parseInt(date[2]),parseInt(date[1])-1,parseInt(date[0]))
        date.valueOf()

    class ChangeExplanation extends Backbone.Model

        defaults:
                year: null
                leading_item: null
                req_code: null
                req_id: null
                explanation: null

        requestId: ->
            if @get('req_id')?
                @get('req_id')
            else
                ret = ""+@get('req_code')
                while ret.length < 3
                        ret = "0"+ret
                ret = @get('leading_item')+'-'+ret
                while ret.length < 6
                        ret = "0"+ret
                ret

        doFetch: ->
                @fetch(dataType: window.pageModel.get('dataType'))

        url: () => "#{window.pageModel.get('baseURL')}/api/change_expl/#{@requestId()}/#{@get('year')}"

    class ChangeLine extends Backbone.Model

        defaults:
                gross_expense_diff: null
                req_code: null
                committee_id: null
                allocated_income_diff: null
                personnel_max_diff: null
                explanation: null
                change_type_name: null
                net_expense_diff: null
                change_title: null
                budget_title: null
                commitment_limit_diff: null
                leading_item: null
                budget_code: null
                year: null
                date: null
                date_type: null
                req_title: null
                change_code: null
                change_type_id: null

        requestId: ->
                ret = ""+@get('req_code')
                while ret.length < 3
                        ret = "0"+ret
                ret = @get('leading_item')+'-'+ret
                while ret.length < 6
                        ret = "0"+ret
                ret

        dateType: ->
                date_type = @get('date_type')
                if date_type == 0
                    ret = "approved"
                if date_type == 1
                    ret = "approved-approximate"
                if date_type == 10
                    ret = "pending"
                console.log 'date_type', date_type, ret
                ret

        initialize: ->
                dateStr = @get 'date'
                if dateStr?
                        @setTimestamp()
                else
                        @on 'change:date', =>
                                @setTimestamp()

        setTimestamp: ->
                @set 'timestamp', dateToTimestamp(@get 'date')

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


    class BudgetItemKids extends Backbone.Collection

        model: BudgetItem

        initialize: (models, options) ->
            @pageModel = options.pageModel
            @year = options.year
            @code = options.code
            @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
            "#{pageModel.get('baseURL')}/api/budget/#{@code}/#{@year}/kids"


    class BudgetItemDepth extends Backbone.Collection

        model: BudgetItem

        initialize: (models, options) ->
            @pageModel = options.pageModel
            @year = options.year
            @code = options.code
            @depth = options.depth
            @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
            "#{pageModel.get('baseURL')}/api/budget/#{@code}/#{@year}/depth/#{@depth}?limit=1000"

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

    class CompareRecords extends Backbone.Collection

        model: CompareRecord

        initialize: (models, options) ->
            @pageModel = options.pageModel
            @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
            "#{pageModel.get('baseURL')}/api/sysprop/budget-comparisons"

        parse: (response) ->
            response.value

    class BudgetApproval extends Backbone.Model
        defaults:
            year: null
            approval_date: null
            effect_date: null
            end_date: null
            approval_timestamp: null
            effect_timestamp: null
            end_timestamp: null
            link: null

        setTimestamps: ->
            @set 'approval_timestamp', dateToTimestamp(@get 'approval_date')
            @set 'effect_timestamp', dateToTimestamp(@get 'effect_date')
            @set 'end_timestamp', dateToTimestamp(@get 'end_date')

    class BudgetApprovals extends Backbone.Collection
        model: BudgetApproval

        initialize: (models, options) ->
            @pageModel = options.pageModel
            @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
            "#{pageModel.get('baseURL')}/api/budget/#{pageModel.get('budgetCode')}/approvals"


    class ChangeLines extends Backbone.Collection

        model: ChangeLine

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/changes/#{pageModel.get('budgetCode')}"

        comparator: 'req_code'

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
                key = "E#{year}/#{code}"
                changes = _.filter(@get('changes'),(c)->_.indexOf(c['equiv_code'],key)>-1)
                d3.sum(changes, (c)->c['expense_change'])

        getDateType: () =>
                if @get('pending') then "pending" else "approved"

        doFetch: ->
                @fetch(dataType: @pageModel.get('dataType'))

        url: ->
                "#{pageModel.get('baseURL')}/api/changegroup/#{pageModel.get('changeGroupId')}/#{pageModel.get('year')}"

    class ChangeGroups extends Backbone.Collection

        model: ChangeGroup

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/changegroup/#{@pageModel.get('budgetCode')}/#{@pageModel.get('year')}/equivs?limit=1000"


    class SupportLineDescription extends Backbone.Model

        defaults:
            field: null,
            en: null,
            he: null,
            model: null,
            order: null

    class SupportFieldNormalizer extends Backbone.Collection

      model: SupportLineDescription

      initialize: (models, options) ->
          @normalizationStructure = {}
          @pageModel = options.pageModel
          @fetch(dataType: @pageModel.get('dataType'), reset: true)
          @on("reset", ->
              _json = @toJSON()
              @normalizationStructure = {}
              for fieldStructure in _json
                  @normalizationStructure[fieldStructure["field"]] = fieldStructure
          )

      normalize: (field, locale) ->
        if @normalizationStructure[field]
        then @normalizationStructure[field][locale]
        else undefined

      url: ->
        "#{@pageModel.get('baseURL')}/api/describe/SupportLine"

    class SupportLine extends Backbone.Model

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
          pageModel = window.pageModel
          for key, value of baseJSON
            normalizedKey = pageModel.supportFieldNormalizer.normalize(key, locale)
            if normalizedKey?
              resultJSON[normalizedKey] = value

          return resultJSON

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

        # toLocaleJSON: (requestedLocale) ->
        #   locale = requestedLocale || "he"
        #   baseJSON = @toJSON()
        #   resultJSON = {}
        #   pageModel = window.pageModel
        #   for key, value of baseJSON
        #     normalizedKey = pageModel.supportFieldNormalizer.normalize(key, locale)
        #     if normalizedKey?
        #       resultJSON[normalizedKey] = value
        #
        #   return resultJSON

    class TakanaSupports extends Backbone.Collection

        model: SupportLine

        comparator: (m) -> "#{m.get('year')} #{m.get('recipient')}"

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/supports/#{@pageModel.get('budgetCode')}?limit=10000"

    class TakanaSpending extends Backbone.Collection

        model: SpendingLine

        comparator: (m) -> m.get('publication_id')

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/exemption/budget/#{@pageModel.get('budgetCode')}?limit=100"

    class NewSpendings extends Backbone.Collection

        model: SpendingLine

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/exemption/new?limit=100"



    class BudgetHistory extends Backbone.Collection

        model: BudgetItem

        initialize: (models, options) ->
                @pageModel = options.pageModel
                @fetch(dataType: @pageModel.get('dataType'), reset: true)

        url: ->
                "#{pageModel.get('baseURL')}/api/budget/#{@pageModel.get('budgetCode')}/#{@pageModel.get('year')}/equivs"

        comparator: (m) -> m.get('year')

        getLast: -> @models[@models.length-1]

    class Participant extends Backbone.Model

        defaults:
                kind: ""
                name: null
                party: null
                photo_url: "data:image/svg+xml;charset=utf-8;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0Ij4NCiAgICA8cGF0aCBkPSJNMTIgMmMtNS41MiAwLTEwIDQuNDgtMTAgMTBzNC40OCAxMCAxMCAxMCAxMC00LjQ4IDEwLTEwLTQuNDgtMTAtMTAtMTB6bTAgM2MxLjY2IDAgMyAxLjM0IDMgM3MtMS4zNCAzLTMgMy0zLTEuMzQtMy0zIDEuMzQtMyAzLTN6bTAgMTQuMmMtMi41IDAtNC43MS0xLjI4LTYtMy4yMi4wMy0xLjk5IDQtMy4wOCA2LTMuMDggMS45OSAwIDUuOTcgMS4wOSA2IDMuMDgtMS4yOSAxLjk0LTMuNSAzLjIyLTYgMy4yMnoiLz4NCiAgICA8cGF0aCBkPSJNMCAwaDI0djI0aC0yNHoiIGZpbGw9Im5vbmUiLz4NCjwvc3ZnPg=="
                start_date: null
                end_date: null
                title: null
                start_timestamp: null
                end_timestamp: null
                unique_id: null

        setTimestamps: ->
            @set 'start_timestamp', dateToTimestamp(@get 'start_date')
            if (@get 'end_date')?
                @set 'end_timestamp', dateToTimestamp(@get 'end_date')
            else
                @set 'end_timestamp', window.combinedHistory.maxTime

            @set('unique_id', @get('title')+"-"+"-"+@get('start_timestamp')+"-"+@get('end_timestamp'))

    class Participants extends Backbone.Collection
        model: Participant

        initialize: (models, options) ->
            @pageModel = options.pageModel
            @code = options.code.substring(0,4)
            @fetch(dataType: window.pageModel.get('dataType'), reset: true)

        url: ->
            "#{pageModel.get('baseURL')}/api/participants/#{@code}?limit=1000"

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
            return "" + d.getDate() + "/" + (d.getMonth() + 1) + "/" + d.getFullYear()

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

    class ReadyAggregator

        constructor: (event) ->
            @readyCounter = 0
            @collections = []
            @models = []
            @event = event
            @ready = false
            if typeof pageModel.events[event] == "function"
                @callback = pageModel.events[event]
                @callback()

            pageModel.events[event] = @

        addModel: (model) ->
            @models.push model
            @readyCounter += 1
            model.on 'change',() => @checkIfReady()
            @

        addCollection: (collection) ->
            @collections.push collection
            @readyCounter += 1
            console.log "addCollection: "+@event+"="+@readyCounter
            collection.on 'reset',() => @checkIfReady()
            @

        checkIfReady: (callback) ->
            if !@ready
                @readyCounter -= 1

            if callback?
                @callback = callback

            console.log "checkIfReady: "+@event+"="+@readyCounter
            if @readyCounter == 0
                @ready = true
                pageModel.trigger(@event)
                if @callback then @callback()

    # window.onresize can only hold 1 callback, the ResizeNotifier will serve as
    # an initiator for onresize events
    class ResizeNotifier
        constructor: ->
            @resizeTimer    = 0
            @callbackQueue  = []

            window.onresize = (event) =>
                clearTimeout(@resizeTimer)
                @resizeTimer = setTimeout ( =>
                  for callback in @callbackQueue
                    callback()
                ), 100

        registerResizeCallback: (callback) ->
            @callbackQueue.push(callback)

    class SelectedEntity extends Backbone.Model
        defaults:
            selected: null
            expandedDetails: {}

    class PageModel extends Backbone.Model

        defaults:
            budgetCode: null
            year: null
            changeGroupId: null
            mainPage: null
            spendingPage: null
            baseURL: "http://www.obudget.org"
            # For debugging with local API
            # Uses default port 8080, make sure this matches your GAE
            # configuration
            #baseURL: "http://127.0.0.1:8080"
            selection: [ 0, 0 ]
            currentItem: null
            dataType: "json"#p"
            ready: false
            kinds: []
            flow: null
            local: true

        initialize: ->
            if window.location.origin == @get('baseURL')
                @set('local', false)
                @set('dataType','json')

            @api = {
                BudgetItemKids: BudgetItemKids
            }

            @events = {}
            @waitFor = (event, callback) ->
                if pageModel.events[event]?
                    pageModel.events[event].checkIfReady(callback)
                else
                    pageModel.events[event] = callback

            @readyEvents = []
            @supportFieldNormalizer = new SupportFieldNormalizer([], pageModel: @)
            @mainPageTabs           = new window.MainPageTabs(@)
            @resizeNotifier         = new ResizeNotifier()
            @selectedEntity         = new SelectedEntity()

            @URLSchemeHandlerInstance = new window.URLSchemeHandler(@)
            window.URLSchemeHandlerInstance = @URLSchemeHandlerInstance

            @resizeNotifier.registerResizeCallback( =>
              @.trigger('resized')
            )

            @on 'change:budgetCode', ->
                budgetCode = @get('budgetCode')
                digits = budgetCode.length - 2
                @set('digits',digits)
                @article.find(".2digits,.4digits,.6digits,.8digits").css('display','none')
                @article.find(".#{digits}digits").css('display','')

                @mainPageTabs.trigger("change:budgetCode")
                #@changeLines = new ChangeLines([], pageModel: @)
                @changeGroups = new ChangeGroups([], pageModel: @)
                @budgetApprovals = new BudgetApprovals([], pageModel: @)
                @budgetHistory = new BudgetHistory([], pageModel: @)
                @budgetHistory.on 'reset',
                                  () =>
                                      console.log 'setting currentItem', @budgetHistory
                                      @set('currentItem', @budgetHistory.getLast())
                                      if @budgetHistory.length > 0
                                          title = @budgetHistory.getLast().get('title')
                                          ga('send', 'event', 'navigation', 'budget', title, 1);
                                          console.log 'setting currentItem done', title

                @readyEvents.push new ReadyAggregator("ready-budget-history-pre")
                                            .addCollection(@changeGroups)
                                            .addCollection(@budgetHistory)
                                            .addCollection(@budgetApprovals)

                if digits >= 4
                    @on('ready-budget-history', ->
                        @supports = new TakanaSupports([], pageModel: @)
                        @readyEvents.push new ReadyAggregator("ready-supports")
                                                    .addCollection(@supports)
                        @spending = new TakanaSpending([], pageModel: @)
                        @readyEvents.push new ReadyAggregator("ready-spending")
                                                    .addCollection(@spending)
                    )
                readyBreadcrumbs = new ReadyAggregator("ready-breadcrumbs")
                                                .addCollection(@budgetHistory)
                @readyEvents.push readyBreadcrumbs
                @breadcrumbs = []
                maxlen=(budgetCode.length/2)-1
                for i in [1..maxlen]
                    main = null
                    kids = null

                    if i < 5
                        code = budgetCode.slice(0,(i+1)*2)
                        main = new BudgetItem(year: @get('year'), code: code, pageModel: @)
                        readyBreadcrumbs.addModel(main)
                        main.on "change:title", ->
                            window.document.title = "מפתח התקציב - #{main.get('title')}"
                        main.do_fetch()
                        kids = new BudgetItemKids([], year: @get('year'), code: code, pageModel: @)
                        readyBreadcrumbs.addCollection(kids)
                        @breadcrumbs.push
                            main: main
                            kids: kids
                            last: i == maxlen

                @on('ready-budget-history', ->
                    @participants = new Participants([], code: budgetCode, pageModel: @)
                    readyParticipants = new ReadyAggregator('ready-participants')
                                                    .addCollection(@participants)
                    @readyEvents.push readyParticipants
                )

            @on 'change:changeGroupId', ->
                @changeGroup = new ChangeGroup(pageModel: @)
                @changeGroupExplanation = new ChangeExplanation(year: pageModel.get('year'), req_id: pageModel.get('changeGroupId'))
                @readyEvents.push new ReadyAggregator("ready-changegroup")
                                            .addModel(@changeGroup)
                @changeGroup.doFetch()
                @changeGroupExplanation.doFetch()
                @changeGroup.on 'change:title_template', =>
                    title_template = @changeGroup.get('title_template')
                    title_template = title_template.split('-')
                    for part in title_template
                        @addKind(part)

            @on 'change:entityId', ->
                @entity = new Entity(pageModel: @, entityId: @URLSchemeHandlerInstance.linkParameters.entityId)
                @readyEvents.push new ReadyAggregator("ready-entity")
                                            .addModel(@entity)
                @entity.doFetch()

            @on 'change:mainPage', ->
                @budgetItems4 = new CompareRecords([], pageModel: @)
                @budgetItems2 = new BudgetItemKids([], year: 2014, code: '00', pageModel: @)
                @readyEvents.push new ReadyAggregator("ready-budget-bubbles")
                                                    .addCollection(@budgetItems2)
                                                    .addCollection(@budgetItems4)

                @mainBudgetItem = new BudgetItem(year: 2014, code: '00', pageModel: @)
                @newBudgetItem = new BudgetItem(year: 2015, code: '00', pageModel: @)
                @readyEvents.push new ReadyAggregator("ready-main-budget")
                                                    .addModel(@mainBudgetItem)
                                                    .addModel(@newBudgetItem)
                @mainBudgetItem.do_fetch()
                @newBudgetItem.do_fetch()

            @on 'change:spendingsPage', ->
                @newSpendings = new NewSpendings([], pageModel: @)
                @readyEvents.push new ReadyAggregator("ready-spendings-page")
                                                    .addCollection(@newSpendings)

            @on 'change:kinds', =>
                for kind in @get('kinds')
                    $('body').toggleClass("kind-#{kind}",true)

        addKind: (kind) ->
            kinds = _.clone(@get('kinds'))
            kinds.push(kind)
            @set('kinds',kinds)

        switchView: (linkParameters) ->
            if !isNaN(linkParameters['year'])
                @set('year',linkParameters['year'])
            else
                window.location.hash = window.DEFAULT_HOME
                return

            kind = linkParameters['kind']
            if kind == "budget"
                @article = $("article#budget-item-article")
                @set("budgetCode","00"+linkParameters['code'])
            else if kind == "transfer"
                @article = $("article#change-group-article")
                @set("changeGroupId",linkParameters['code'])
            else if kind == "entity"
                @article = $("article#entity-article")
                @set("entityId",linkParameters['entityId'])
            else if kind == "main"
                @article = $("article#main-page-article")
                @set("mainPage",true)
            else if kind == "spending"
                @article = $("article#spendings-page-article")
                @set("spendingsPage",true)
            else
                window.location.hash = window.DEFAULT_HOME
                return

            @set("flow",linkParameters['flow'])
            $("article.single-page-article").css("display","none")
            @article.css("display","inherit")
            @addKind(kind)


    models = {
        BudgetItem: BudgetItem
        ChangeLine: ChangeLine
        ChangeExplanation: ChangeExplanation
        Entity: Entity,
        pageModel: new PageModel()
    }

    # TODO remove all global variables and use dependancies
    window.models = models
    window.pageModel = models.pageModel
    window.pageModel
        .switchView(pageModel.URLSchemeHandlerInstance.linkParameters)

    return models
