define ['backbone',
        'scripts/modelsHelpers/BudgetItemKids',
        'scripts/modelsHelpers/SupportFieldNormalizer',
        'scripts/modelsHelpers/ResizeNotifier',
        'scripts/modelsHelpers/ChangeGroup',
        'scripts/modelsHelpers/ChangeGroups',
        'scripts/modelsHelpers/ChangeExplanation',
        'scripts/modelsHelpers/BudgetApprovals',
        'scripts/modelsHelpers/BudgetHistory',
        'scripts/modelsHelpers/ReadyAggregator',
        'scripts/modelsHelpers/CompareRecords',
        'scripts/modelsHelpers/BudgetItem',
        'scripts/modelsHelpers/TakanaSupports',
        'scripts/modelsHelpers/TakanaSpending',
        'scripts/modelsHelpers/Participants'
      ], (Backbone, BudgetItemKids, SupportFieldNormalizer, ResizeNotifier, ChangeGroup,
      ChangeGroups, ChangeExplanation, BudgetApprovals, BudgetHistory, ReadyAggregator, CompareRecords, BudgetItem,
      TakanaSupports, TakanaSpending, Participants) ->

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

          @readyEvents = []
          @supportFieldNormalizer = new SupportFieldNormalizer([], pageModel: @)
          @mainPageTabs           = new window.MainPageTabs(@)
          @resizeNotifier         = new ResizeNotifier()

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
                                    year = @get('year')
                                    @set('currentItem', @budgetHistory.getForYear(year))
                                    if @budgetHistory.length > 0
                                        title = @budgetHistory.getForYear(year).get('title')
                                        ga('send', 'event', 'navigation', 'budget', title, 1);

              @readyEvents.push (new ReadyAggregator("ready-budget-history-pre")
                                        .addCollection(@changeGroups)
                                        .addCollection(@budgetHistory)
                                        .addCollection(@budgetApprovals))

              if digits >= 4
                  @on('ready-budget-history', ->
                      @supports = new TakanaSupports([], pageModel: @)
                      @readyEvents.push (new ReadyAggregator("ready-supports")
                                                  .addCollection(@supports))
                      @spending = new TakanaSpending([], pageModel: @)
                      @readyEvents.push (new ReadyAggregator("ready-spending")
                                                  .addCollection(@spending))
                  )
              readyBreadcrumbs = (new ReadyAggregator("ready-breadcrumbs")
                                              .addCollection(@budgetHistory))
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
                  readyParticipants = (new ReadyAggregator('ready-participants')
                                                  .addCollection(@participants))
                  @readyEvents.push readyParticipants
              )

          @on 'change:changeGroupId', ->
              @changeGroup = new ChangeGroup(pageModel: @)
              @changeGroupExplanation = new ChangeExplanation(year: pageModel.get('year'), req_id: pageModel.get('changeGroupId'))
              @readyEvents.push (new ReadyAggregator("ready-changegroup")
                                          .addModel(@changeGroup))
              @changeGroup.doFetch()
              @changeGroupExplanation.doFetch()
              @changeGroup.on 'change:title_template', =>
                  title_template = @changeGroup.get('title_template')
                  title_template = title_template.split('-')
                  for part in title_template
                      @addKind(part)

          @on 'change:mainPage', ->
              @budgetItems4 = new CompareRecords([], pageModel: @)
              @budgetItems2 = new BudgetItemKids([], year: 2014, code: '00', pageModel: @)
              @readyEvents.push (new ReadyAggregator("ready-budget-bubbles")
                                                  .addCollection(@budgetItems2)
                                                  .addCollection(@budgetItems4))

              @mainBudgetItem = new BudgetItem(year: 2014, code: '00', pageModel: @)
              @newBudgetItem = new BudgetItem(year: 2015, code: '00', pageModel: @)
              @readyEvents.push (new ReadyAggregator("ready-main-budget")
                                                  .addModel(@mainBudgetItem)
                                                  .addModel(@newBudgetItem))
              @mainBudgetItem.do_fetch()
              @newBudgetItem.do_fetch()

          @on 'change:kinds', =>
              for kind in @get('kinds')
                  $('body').toggleClass("kind-#{kind}",true)

      eventAlreadyTriggered: (eventName) =>
        @get 'event-triggered-' + eventName || false

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

  return PageModel
