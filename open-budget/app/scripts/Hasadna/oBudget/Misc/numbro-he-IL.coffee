define ['vendor/numbro'], (numbro) ->
  # /*!
  #  * numbro.js language configuration
  #  * language : Hebrew
  #  * locale : IL
  #  * author : Eli Zehavi : https://github.com/eli-zehavi
  #  */
##
  language =
      langLocaleCode: 'he-IL'
      cultureCode: 'he-IL'
      delimiters:
          thousands: ','
          decimal: '.'

      abbreviations:
          thousand: 'אלף'
          million: 'מליון',
          billion: 'מיליארד'
          trillion: 'טריליון'

      currency:
          symbol: '₪'
          position: 'postfix'

      defaults:
          currencyFormat: ',4 a'

      formats:
          fourDigits: '4 a'
          fullWithTwoDecimals: '₪ ,0.00'
          fullWithTwoDecimalsNoCurrency: ',0.00'
          fullWithNoDecimals: '₪ ,0'


  window.numbro.culture(language.cultureCode, language);
