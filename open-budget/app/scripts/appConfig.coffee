define({
  baseURL: if window.location.protocol == 'https:' then 'https://open-budget-il.appspot.com/' else 'http://www.obudget.org',
  dataType: 'json',
  local: window.location.origin == 'http://www.obudget.org',
});
