import CombinedHistory from 'scripts/combined_history';
import OverviewWidget from 'scripts/history_widget';
import IndepthWidget from 'scripts/indepth_widget';
import SupportList from 'scripts/support_list';
import SupporPivotTable from 'scripts/support_pivot_table';
import SpendingList from 'scripts/spending_list';
import SpendingPivotTable from 'scripts/spending_pivot_table';
import HistoryTable from 'scripts/detailed_history';

export function start(pageModel) {
  const combinedHistory = new CombinedHistory(null, {
    pageModel,
  });

  if (pageModel.get('budgetCode')) {
    pageModel.on('ready-budget-history', () => {
      const overviewWidget = new OverviewWidget({
        el: '#overview-widget', model: combinedHistory, pageModel,
      });

      return overviewWidget;
    });
  }

  const indepthWidget = new IndepthWidget({
    el: '#indepth-widget', model: combinedHistory, pageModel,
  });

  pageModel.on('ready-budget-history', () => {
    indepthWidget.render();
  });

  pageModel.on('ready-participants', () => {
    indepthWidget.setParticipants(pageModel.participants.models);
    indepthWidget.render();
  });

  const supportList = new SupportList({ el: '#support-lines', model: pageModel });

  const supporPivotTable = new SupporPivotTable({
    el: '#support-pivottable-content', model: pageModel,
  });

  const spendingList = new SpendingList({ el: '#spending-lines', model: pageModel });

  const spendingPivotTable = new SpendingPivotTable({
    el: '#spending-pivottable-content', model: pageModel,
  });

  let historyTable;
  if (pageModel.get('budgetCode')) {
    historyTable = new HistoryTable({ el: '#change-list', model: combinedHistory });
  }

  return {
    supportList,
    supporPivotTable,
    spendingList,
    spendingPivotTable,
    historyTable,
  };
}

