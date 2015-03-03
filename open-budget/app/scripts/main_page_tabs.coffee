class MainPageTabs extends Backbone.View
  initialize: (pageModel) ->
    self = this;
    @pageModel    = pageModel
    @tabList      = $(".tab-label")
    @contentList  = $(".tab-content")
    @tabHeader    = $("#tabs-label-container")
    $(".tab-label").click ->
      # Get the index of the clicked tab
      tabIndex = $(this).index()
      self.showTab(tabIndex)

    @on 'change:budgetCode', ->
      digits = @pageModel.get("digits")
      if digits >=4 then @tabHeader.show() else @tabHeader.hide()


    # show the first tab
    @showTab(0);

  showTab: (tabIndex) ->
    # Hide all the content DIVs and return the DIV corresponding to the
    # requested index
    contentElement = @contentList.hide().get(tabIndex)
    # de-select all the tabs
    @tabList.filter(".selected").removeClass("selected")
    # select the requested tab
    $(@tabList.get(tabIndex)).addClass("selected")
    # Show the selected content DIV
    $(contentElement).show()

window.MainPageTabs = MainPageTabs
