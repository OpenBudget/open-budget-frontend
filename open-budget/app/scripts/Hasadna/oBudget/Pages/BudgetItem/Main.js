import View from 'Hasadna/oBudget/Pages/BudgetItem/View';
import BreadcrumbHeaderView from 'Hasadna/oBudget/Pages/BudgetItem/breadcrumb_header';
import AnalysisHeader from 'Hasadna/oBudget/Pages/BudgetItem/AnalysisHeader';
import * as dataFetchers from 'Hasadna/oBudget/Misc/dataFetchers';
import CombinedHistory from 'Hasadna/oBudget/Pages/BudgetItem/CombinedHistory';
import OverviewWidget from 'Hasadna/oBudget/Pages/BudgetItem/OverviewWidget';
import IndepthWidget from 'Hasadna/oBudget/Pages/BudgetItem/IndepthWidget';
import SupportList from 'Hasadna/oBudget/Pages/BudgetItem/support_list';
import SupporPivotTable from 'Hasadna/oBudget/Pages/BudgetItem/support_pivot_table';
import SpendingList from 'Hasadna/oBudget/Pages/BudgetItem/spending_list';
import MainPageTabs from 'Hasadna/oBudget/Pages/BudgetItem/MainPageTabs';
import Backbone from 'backbone';

// SpendingPivotTable is doing nothig ??
// import SpendingPivotTable from 'scripts/spending_pivot_table';
import HistoryTable from 'Hasadna/oBudget/Pages/BudgetItem/HistoryTable';

export default class Main {
  constructor(budgetCode, budgetYear, urlSchemeHandler, pageWithTourReadyResolve) {
    this.pageWithTourReadyResolve = pageWithTourReadyResolve;
    this.budgetCode = budgetCode;
    this.budgetYear = budgetYear;
    this.budgetCodeLength = budgetCode.length - 2;
    this.currentItem = null;
    this.urlSchemeHandler = urlSchemeHandler;

    this.view = new View();
    this.view.render();

    this.view.$el.find('.2digits,.4digits,.6digits,.8digits').css('display', 'none');
    this.view.$el.find(`.${this.budgetCodeLength}digits`).css('display', '');

    this.fetchData();

    this.more();
  }

  fetchData() {
    this.dataPromises = {
      breadcrumbs: dataFetchers.getBreadcrumbsData(this.budgetCode, this.budgetYear),
      budgetApprovals: dataFetchers.budgetApprovals(this.budgetCode),
      budgetHistory: dataFetchers.budgetHistory(this.budgetCode, this.budgetYear),
      participants: dataFetchers.participants(this.budgetCode),
    };

    this.dataPromises.currentItem = this.dataPromises.budgetHistory
                                      .then(history => history.getForYear(this.budgetYear));

    // Selective data fetching

    if (this.budgetCodeLength > 2) {
      // We need this data only when this.budgetCodeLength > 2,
      // but for simplifying the flow we are gonna create it anyhow as empty promise
      this.dataPromises.changeGroups = dataFetchers.changeGroups(this.budgetCode, this.budgetYear);
    } else {
      this.dataPromises.changeGroups = Promise.resolve({ models: [] });
    }

    if (this.budgetCodeLength >= 4) {
      this.dataPromises.supportFieldNormalizer = dataFetchers.getSupportFieldNormalizer();

      this.dataPromises.takanaSupports = this.dataPromises.supportFieldNormalizer
        .then(
          (supportFieldNormalizer) =>
            dataFetchers.takanaSupports(this.budgetCode, supportFieldNormalizer)
        );

      this.dataPromises.takanaSpending = dataFetchers.takanaSpending(this.budgetCode);
    }
  }

  more() {
    this.dataPromises.breadcrumbs
      .then((breadcrumbs) => {
        window.document.title =
          `מפתח התקציב - ${breadcrumbs[breadcrumbs.length - 1].main.get('title')}`;

        const breadcrumbHeaderView = new BreadcrumbHeaderView({
          el: '#header-tree', breadcrumbs,
        });
        breadcrumbHeaderView.render();

        this.view.$el.find('#affix-wrapper').height(this.view.$el.find('#affix-header').height());
      });


    Promise.all([
      this.dataPromises.budgetHistory,
      this.dataPromises.breadcrumbs,
      // when this.budgetCodeLength < 2 this is gonna be just Promise.resolve()
      this.dataPromises.changeGroups,
      this.dataPromises.currentItem,
    ]).then((data) => {
      const analysisHeader = new AnalysisHeader({
        el: this.view.$el.find('.brief'),
        model: this.model,
        changeGroups: data[2],
        budgetCode: this.budgetCode,
        currentItem: data[3],
      });

      return analysisHeader;
    });


    if (this.budgetCodeLength >= 4) {
      Promise.all([
        this.dataPromises.takanaSupports,
      ]).then((data) => {
        const supportList = new SupportList({
          el: this.view.$el.find('#support-lines').get(0),
          supportsCollection: data[0],
        });
        supportList.toString();
      });

      Promise.all([
        this.dataPromises.takanaSupports,
        this.dataPromises.supportFieldNormalizer,
      ])
      .then((data) => {
        const supporPivotTable = new SupporPivotTable({
          el: this.view.$el.find('#support-pivottable-content'),
          supports: data[0],
          supportFieldNormalizer: data[1],
        });
        supporPivotTable.render();
      });

      this.dataPromises.takanaSpending.then((takanaSpending) => {
        const spendingList = new SpendingList({
          el: this.view.$el.find('#spending-lines').get(0),
          spending: takanaSpending,
        });

        spendingList.render();
        //  SpendingPivotTable is doing nothig ??
        //   const spendingPivotTable = new SpendingPivotTable({
        //     el: this.view.$el.find('#spending-pivottable-content'),
        //     spending: takanaSpending,
        //   });

        //   spendingPivotTable.toString();
      });
    }

    Promise.all([
      this.dataPromises.budgetHistory,
      this.dataPromises.budgetApprovals,
      this.dataPromises.changeGroups,
      this.budgetCode,
      this.dataPromises.participants,
    ])
    .then(this.combinedHistoryFlow.bind(this));
  }

  combinedHistoryFlow(data) {
    const [budgetHistory, budgetApprovals, changeGroups, budgetCode, participants] = data;
    const selectionModel = new Backbone.Model({
      selection: [0, 0],
    });

    const combinedHistory = new CombinedHistory(null, {
      budgetHistory,
      budgetApprovals,
      changeGroups,
      budgetCode,
    });

    const overviewWidget = new OverviewWidget({
      el: this.view.$el.find('#overview-widget'),
      model: combinedHistory,
      budgetCode,
      selectionModel,
    });

    overviewWidget.toString();

    const indepthWidget = new IndepthWidget({
      el: this.view.$el.find('#indepth-widget'), model: combinedHistory, budgetCode, selectionModel,
    });

    indepthWidget.render();
    indepthWidget.setParticipants(participants.models);
    indepthWidget.render();

    const historyTable = new HistoryTable({
      el: this.view.$el.find('#change-list'), model: combinedHistory,
    });

    historyTable.toString();

    const mainPageTabs = new MainPageTabs({
      budgetCode,
      digits: this.budgetCodeLength,
    });

    mainPageTabs.toString();

    mainPageTabs.on('tab-select', (tab) => {
      this.urlSchemeHandler.addAttribute('tab', tab, false);
    });

    this.pageWithTourReadyResolve();
  }

  getView() {
    return this.view;
  }

  afterAppend() {

  }
}
