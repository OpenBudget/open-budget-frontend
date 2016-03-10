import * as dataFetchers from 'Hasadna/oBudget/Misc/dataFetchers';
import MainPageVis from 'Hasadna/oBudget/Pages/Main/main_page_vis';
import View from 'Hasadna/oBudget/Pages/Main/View';

export default class Main {
  constructor(URLSchemeHandlerInstance, pageWithTourReadyResolve) {
    this.pageWithTourReadyResolve = pageWithTourReadyResolve;
    this.URLSchemeHandlerInstance = URLSchemeHandlerInstance;
    this.view = new View();

    this.dataPromises = {
      // @budgetItems4 = new CompareRecords([], pageModel: @)
      compareRecords: dataFetchers.compareRecords(),
      // @budgetItems2 = new BudgetItemKids([], year: 2015, code: '00', pageModel: @)
      budgetItemKids: dataFetchers.budgetItemKids('00', 2015),
      mainBudgetItem: dataFetchers.budgetItem('00', 2015),
      newBudgetItem: dataFetchers.budgetItem('00', 2016),
    };

    // @budgetItems4 = new CompareRecords([], pageModel: @)
    // @budgetItems2 = new BudgetItemKids([], year: 2015, code: '00', pageModel: @)
    // @readyEvents.push (new ReadyAggregator(@, "ready-budget-bubbles")
    //                                     .addCollection(@budgetItems2)
    //                                     .addCollection(@budgetItems4))

    // @mainBudgetItem = new BudgetItem(year: 2015, code: '00', pageModel: @)
    // @newBudgetItem = new BudgetItem(year: 2016, code: '00', pageModel: @)
    // @readyEvents.push (new ReadyAggregator(@, "ready-main-budget")
    //                                     .addModel(@mainBudgetItem)
    //                                     .addModel(@newBudgetItem))
    // @mainBudgetItem.do_fetch()
    // @newBudgetItem.do_fetch()
  }

  getView() {
    return this.view;
  }

  afterAppend() {
    Promise.all([
      this.dataPromises.compareRecords,
      this.dataPromises.budgetItemKids,
      this.dataPromises.mainBudgetItem,
      this.dataPromises.newBudgetItem,
    ])
      .then((data) => {
        const mainPageVis = new MainPageVis({
          el: this.view.el,
          compareRecords: data[0],
          budgetItemKids: data[1],
          mainBudgetItem: data[2],
          newBudgetItem: data[3],
          URLSchemeHandlerInstance: this.URLSchemeHandlerInstance,
        });

        mainPageVis.toString();

        this.pageWithTourReadyResolve();
      });
  }
}
