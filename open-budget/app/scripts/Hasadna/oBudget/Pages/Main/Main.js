import * as dataFetchers from 'Hasadna/oBudget/Misc/dataFetchers';
import MainPageVis from 'Hasadna/oBudget/Pages/Main/main_page_vis';
import View from 'Hasadna/oBudget/Pages/Main/View';

export default class Main {
  constructor(URLSchemeHandlerInstance, pageWithTourReadyResolve) {
    this.pageWithTourReadyResolve = pageWithTourReadyResolve;
    this.URLSchemeHandlerInstance = URLSchemeHandlerInstance;
    this.view = new View();

    this.dataPromises = {
      compareRecords: dataFetchers.compareRecords(),
      budgetItemKids: dataFetchers.budgetItemKids('00', 2017),
      mainBudgetItem: dataFetchers.budgetItem('00', 2016),
      newBudgetItem: dataFetchers.budgetItem('00', 2017),
    };
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
