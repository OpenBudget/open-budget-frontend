define(['backbone', 'bootstrap', 'bubble_chart'], (Backbone, BubbleChart) ->

    class MainPageTabs extends Backbone.View
      initialize: (pageModel) ->
        self = this;
        @pageModel    = pageModel
        @tabList      = $(".tab-label")
        @contentList  = $(".tab-content")
        @tabHeader    = $("#tabs-label-container")

        $(".tab-label a").click( (e) ->
            e.preventDefault()
            $(this).tab("show")
            pageModel.URLSchemeHandlerInstance.addAttribute("tab", $(this).attr("data-name"), false)
          )

        activeTab = $("#list-title a")
        if (pageModel.URLSchemeHandlerInstance)
            switch pageModel.URLSchemeHandlerInstance.getAttribute('tab')
                # Changes are selected by default - no need for explicit selection
                # when 'changes' then $("#list-title")
                when 'supports' then activeTab = $("#support-list-title a")

        activeTab.tab("show")

        @on 'change:budgetCode', ->
          digits = @pageModel.get("digits")
          if digits >=4 then @tabHeader.show() else @tabHeader.hide()

    window.MainPageTabs = MainPageTabs

    return MainPageTabs
)
