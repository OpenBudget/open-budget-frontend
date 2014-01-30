(function() {
  console.log("'Allo from CoffeeScript!");

  $(function() {
    console.log('setting up typeahead');
    $("#search-item").typeahead({
      name: 'budgets',
      limit: 20,
      engine: Hogan,
      template: ['<p class="item-code">{{code}}</p>', '<p class="item-title">{{title}}</p>'].join(''),
      remote: {
        url: window.pageModel.get('baseURL') + '/api/search/budget/2013?q=%QUERY&limit=20',
        dataType: 'jsonp',
        filter: function(l) {
          var x, _i, _len;
          for (_i = 0, _len = l.length; _i < _len; _i++) {
            x = l[_i];
            x._code = x.code.substring(2);
            x.value = x._code;
          }
          return l;
        }
      }
    });
    $('.typeahead.input-sm').siblings('input.tt-hint').addClass('hint-small');
    return $('.typeahead.input-lg').siblings('input.tt-hint').addClass('hint-large');
  });

}).call(this);
