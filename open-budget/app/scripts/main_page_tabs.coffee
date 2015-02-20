class MainPageTabs extends Backbone.View
  initialize: ->
    self = this;
    $(".tab-label").click ->
      # Get the index of the clicked tab
      tabIndex = $(this).index();
      self.showTab(tabIndex);
    
    # show the first tab
    @showTab(0);
  
  showTab: (tabIndex) ->
    contentList = $(".tab-content");
    tabList = $(".tab-label");
    # Hide all the content DIVs and return the DIV corresponding to the
    # requested index
    contentElement = contentList.hide().get(tabIndex);
    # de-select all the tabs
    tabList.filter(".selected").removeClass("selected");
    # select the requested tab
    $(tabList.get(tabIndex)).addClass("selected");
    # Show the selected content DIV
    $(contentElement).show();

$( ->
  console.log "main_page_tabs"
  window.supportList = new MainPageTabs();
)