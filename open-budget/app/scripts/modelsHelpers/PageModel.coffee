define [
        'backbone',
        'underscore',
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
      ], (Backbone, _, BudgetItemKids, SupportFieldNormalizer, ResizeNotifier, ChangeGroup,
      ChangeGroups, ChangeExplanation, BudgetApprovals, BudgetHistory, ReadyAggregator, CompareRecords, BudgetItem,
      TakanaSupports, TakanaSpending, Participants) ->

  class PageModel extends Backbone.Model

      defaults:
          budgetCode: null
          year: null
          changeGroupId: null
          mainPage: null
          spendingPage: null
          selection: [ 0, 0 ]
          currentItem: null
          ready: false
          kinds: []
          flow: null

      initialize: (attrs, options) ->

          @DEFAULT_HOME = options.DEFAULT_HOME

          @readyEvents = []
          @supportFieldNormalizer = new SupportFieldNormalizer([])
          @resizeNotifier         = new ResizeNotifier()

          @resizeNotifier.registerResizeCallback( =>
            @.trigger('resized')
          )

          @on 'change:budgetCode', @budgetCodeChange

          @on 'change:changeGroupId', ->
              return
              @changeGroup = new ChangeGroup(null, pageModel: @)
              @changeGroupExplanation = new ChangeExplanation(year: @get('year'), req_id: @get('changeGroupId'))
              @readyEvents.push (new ReadyAggregator(@, "ready-changegroup")
                                          .addModel(@changeGroup))
              @changeGroup.doFetch()
              @changeGroupExplanation.doFetch()
              @changeGroup.on 'change:title_template', =>
                  title_template = @changeGroup.get('title_template')
                  title_template = title_template.split('-')
                  for part in title_template
                      @addKind(part)

          @on 'change:kinds', =>
              for kind in @get('kinds')
                  $('body').toggleClass("kind-#{kind}",true)

      budgetCodeChange: () ->
        budgetCode = @get('budgetCode')

        return;

        #@changeLines = new ChangeLines([], pageModel: @)
        @budgetApprovals = new BudgetApprovals([], pageModel: @)
        @budgetHistory = new BudgetHistory([], pageModel: @)
        @budgetHistory.on 'reset',
                          () =>
                              year = @get('year')
                              @set('currentItem', @budgetHistory.getForYear(year))
                              if @budgetHistory.length > 0
                                  title = @budgetHistory.getForYear(year).get('title')
                                  ga('send', 'event', 'navigation', 'budget', title, 1);
        aggregator = new ReadyAggregator(@, "ready-budget-history-pre")
                                  .addCollection(@budgetHistory)
                                  .addCollection(@budgetApprovals)
        if digits > 2
            @changeGroups = new ChangeGroups([], pageModel: @)
            aggregator.addCollection(@changeGroups)
        @readyEvents.push (aggregator)

        if digits >= 4
            @on('ready-budget-history', ->
                @supports = new TakanaSupports([], pageModel: @)
                @readyEvents.push (new ReadyAggregator(@, "ready-supports")
                                            .addCollection(@supports))
                @spending = new TakanaSpending([], pageModel: @)
                @readyEvents.push (new ReadyAggregator(@, "ready-spending")
                                            .addCollection(@spending))
            )
        readyBreadcrumbs = (new ReadyAggregator(@, "ready-breadcrumbs")
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
            readyParticipants = (new ReadyAggregator(@, 'ready-participants')
                                            .addCollection(@participants))
            @readyEvents.push readyParticipants
        )


      eventAlreadyTriggered: (eventName) =>
        @get 'event-triggered-' + eventName || false

      addKind: (kind) ->
          kinds = _.clone(@get('kinds'))
          kinds.push(kind)
          @set('kinds',kinds)

      switchView: (linkParameters) ->
          if !isNaN(linkParameters['year'])
              @set('year',linkParameters['year'])
          # else
          #     window.location.hash = @DEFAULT_HOME
          #     return

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
          # else
          #     window.location.hash = @DEFAULT_HOME
          #     return

          @set("flow",linkParameters['flow'])
          $("article.single-page-article").css("display","none")
          @article.css("display","inherit")
          @addKind(kind)

  return PageModel
