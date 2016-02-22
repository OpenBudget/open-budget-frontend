import numbro from 'vendor/numbro';
// /*!
//  * numbro.js language configuration
//  * language : Hebrew
//  * locale : IL
//  * author : Eli Zehavi : https://github.com/eli-zehavi
//  */
// #
const language = {
  langLocaleCode: 'he-IL',
  cultureCode: 'he-IL',
  delimiters: {
    thousands: ',',
    decimal: '.',
  },
  abbreviations: {
    thousand: 'אלף',
    million: 'מיליון',
    billion: 'מיליארד',
    trillion: 'טריליון',
  },
  currency: {
    symbol: '₪',
    position: 'postfix',
  },
  defaults: {
    currencyFormat: ',4 a',
  },
  formats: {
    fourDigits: '4 a',
    fullWithTwoDecimals: '₪ ,0.00',
    fullWithTwoDecimalsNoCurrency: ',0.00',
    fullWithNoDecimals: '₪ ,0',
  },
};

numbro.culture(language.cultureCode, language);
