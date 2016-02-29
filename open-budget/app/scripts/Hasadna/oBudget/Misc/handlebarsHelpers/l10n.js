const heIl = require('Hasadna/oBudget/l10n/he-IL').default;

const i18n = (...args) => {
  const i18nRet = args.slice(0, args.length - 1)
    .map((currenyKey) => {
      if (!heIl[currenyKey]) {
        throw new Error(`l10n key [${currenyKey}] not found`);
      }

      return heIl[currenyKey];
    }).join(' ');

  return i18nRet;
};

module.exports = i18n;
