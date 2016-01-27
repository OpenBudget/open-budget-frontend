define([
    'scripts/combined_history',
    'scripts/history_widget',
    'scripts/indepth_widget',
    "scripts/support_list",
    "scripts/support_pivot_table",
    "scripts/spending_list",
    "scripts/spending_pivot_table",
    "scripts/detailed_history"
    ],
      function (
        CombinedHistory,
        OverviewWidget,
        IndepthWidget,
        SupportList,
        SupporPivotTable,
        SpendingList,
        SpendingPivotTable,
        HistoryTable
      ) {
      return {
        start: function (pageModel) {
          var combinedHistory = new CombinedHistory(null, {
            pageModel: pageModel
          });

          if (pageModel.get('budgetCode')) {
            pageModel.on('ready-budget-history', function () {
              var overviewWidget = new OverviewWidget({el: "#overview-widget", model: combinedHistory, pageModel: pageModel});
            });
          }

          var indepthWidget = new IndepthWidget({el: "#indepth-widget", model: combinedHistory, pageModel: pageModel});

          pageModel.on('ready-budget-history', function () {
            indepthWidget.render();
          });

          pageModel.on('ready-participants', function () {
              indepthWidget.setParticipants(pageModel.participants.models)
              indepthWidget.render()
          });

          var supportList = new SupportList({el: "#support-lines", model: pageModel});

          var supporPivotTable = new SupporPivotTable({el: "#support-pivottable-content", model: pageModel});

          var spendingList = new SpendingList({el: "#spending-lines", model: pageModel});

          var spendingPivotTable = new SpendingPivotTable({el: "#spending-pivottable-content", model: pageModel});

          if (pageModel.get('budgetCode')) {
            var historyTable = new HistoryTable({el: "#change-list", model: combinedHistory})
          }
        }
      };
    }
);
