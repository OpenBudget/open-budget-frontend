define(['backbone', 'jquery', 'scripts/bubble_chart', 'bootstrap'], (Backbone, $, BubbleChart) ->

    class MainPageTabs extends Backbone.View
      initialize: (options) ->
        @URLSchemeHandlerInstance = URLSchemeHandlerInstance;
        @tabList      = $(".tab-label")
        @contentList  = $(".tab-content")
        @tabHeader    = $("#tabs-label-container")

        self = @

        $(".tab-label a").click( (e) ->
            e.preventDefault()
            $(this).tab("show")
            self.URLSchemeHandlerInstance.addAttribute("tab", $(this).attr("data-name"), false)
          )

        activeTab = $("#list-title a")
        if (@URLSchemeHandlerInstance)
            switch @URLSchemeHandlerInstance.getAttribute('tab')
                # Changes are selected by default - no need for explicit selection
                # when 'changes' then $("#list-title")
                when 'supports' then activeTab = $("#support-list-title a")

        activeTab.tab("show")

        showOrHide = =>
          digits = @model.get("digits")
          if digits >=4 then @tabHeader.show() else @tabHeader.hide()

        if @model.get('budgetCode')
          showOrHide()


        @listenTo(@model, 'change:budgetCode', showOrHide)

    return MainPageTabs
)
