import BudgetApprovals from 'scripts/modelsHelpers/BudgetApprovals';
import BudgetHistory from 'scripts/modelsHelpers/BudgetHistory';
import ChangeGroups from 'scripts/modelsHelpers/ChangeGroups';
import TakanaSupports from 'scripts/modelsHelpers/TakanaSupports';
import TakanaSpending from 'scripts/modelsHelpers/TakanaSpending';
import BudgetItem from 'scripts/modelsHelpers/BudgetItem';
import BudgetItemKids from 'scripts/modelsHelpers/BudgetItemKids';
import Participants from 'scripts/modelsHelpers/Participants';
import SupportFieldNormalizer from 'scripts/modelsHelpers/SupportFieldNormalizer';
import CompareRecords from 'scripts/modelsHelpers/CompareRecords';
import ChangeGroup from 'scripts/modelsHelpers/ChangeGroup';
import ChangeExplanation from 'scripts/modelsHelpers/ChangeExplanation';


export function changeExplanation(changeGroupId, budgetYear) {
  return new Promise((resolve, reject) => {
    const model = new ChangeExplanation({ year: budgetYear, req_id: changeGroupId });

    model.fetch().then(() => {
      resolve(model);
    }).fail(reject);
  });
}

export function changeGroup(changeGroupId, budgetYear) {
  return new Promise((resolve, reject) => {
    const model = new ChangeGroup(null, { changeGroupId, budgetYear });

    model.fetch().then(() => {
      resolve(model);
    }).fail(reject);
  });
}

export function compareRecords() {
  return new Promise((resolve, reject) => {
    const coll = new CompareRecords();

    coll.fetch().then(() => {
      resolve(coll);
    }).fail(reject);
  });
}

export function budgetApprovals(budgetCode) {
  return new Promise((resolve, reject) => {
    const coll = new BudgetApprovals([], { budgetCode });

    coll.fetch().then(() => {
      resolve(coll);
    }).fail(reject);
  });
}

export function budgetHistory(budgetCode, budgetYear) {
  return new Promise((resolve, reject) => {
    const coll = new BudgetHistory([], { budgetCode, budgetYear });

    coll.fetch().then(() => {
      resolve(coll);
    }).fail(reject);
  });
}

export function changeGroups(budgetCode, budgetYear) {
  return new Promise((resolve, reject) => {
    const coll = new ChangeGroups([], { budgetCode, budgetYear });

    coll.fetch().then(() => {
      resolve(coll);
    }).fail(reject);
  });
}

export function getSupportFieldNormalizer() {
  return new Promise((resolve, reject) => {
    const coll = new SupportFieldNormalizer([]);

    coll.fetch().then(() => {
      resolve(coll);
    }).fail(reject);
  });
}

export function takanaSupports(budgetCode, supportFieldNormalizer, offset = 0, limit = 10000) {
  return new Promise((resolve, reject) => {
    const coll = new TakanaSupports([], { budgetCode, supportFieldNormalizer, offset, limit });

    coll.fetch().then(() => {
      resolve(coll);
    }).fail(reject);
  });
}

export function takanaSpending(budgetCode, offset = 0, limit = 100) {
  return new Promise((resolve, reject) => {
    const coll = new TakanaSpending([], { budgetCode, offset, limit });

    coll.fetch().then(() => {
      resolve(coll);
    }).fail(reject);
  });
}

export function participants(budgetCode, offset = 0, limit = 1000) {
  return new Promise((resolve, reject) => {
    const coll = new Participants([], { budgetCode, offset, limit });

    coll.fetch().then(() => {
      resolve(coll);
    }).fail(reject);
  });
}

export function budgetItem(budgetCode, year) {
  return new Promise((resolve, reject) => {
    const model = new BudgetItem({ code: budgetCode, year });

    model.fetch().then(() => {
      resolve(model);
    }).fail(reject);
  });
}

export function budgetItemKids(budgetCode, year) {
  return new Promise((resolve, reject) => {
    const coll = new BudgetItemKids([], { code: budgetCode, year });

    coll.fetch().then(() => {
      resolve(coll);
    }).fail(reject);
  });
}

export function getBreadcrumbsData(budgetCode, year) {
  const breadcrumbsSeed = [];

  const maxlen = (budgetCode.length / 2) - 1;
  if (maxlen === 0) {
    breadcrumbsSeed.push({
      year,
      code: budgetCode,
      last: true,
    });
  } else {
    // Ignore the top level row
    for (let i = 1; i <= maxlen; i++) {
      if (i >= 5) {
        // console.warn('budgetCode / maxlen is longer then expected ?');
        break;
      }

      const code = budgetCode.slice(0, (i + 1) * 2);

      breadcrumbsSeed.push({
        year,
        code,
        last: i === maxlen,
      });
    }
  }

  return Promise.all(breadcrumbsSeed.map((level) =>
    Promise.all([
      level,
      budgetItem(level.code, level.year),
      budgetItemKids(level.code, level.year),
    ])
  ))
  .then((values) => {
    const arr = values.map(([level, main, kids]) => {
      const data = {
        main,
        kids,
        last: level.last,
      };

      return data;
    });

    return arr;
  });
}
