'use strict';

var data = function(handler) {
    return function(response) {
        return handler(response.data);
    };
};
/**
 * @ngdoc function
 * @name matchesApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the matchesApp
 */
angular.module('matchesApp')
  .controller('MainCtrl', ['$http', '$window', function ($http,$window) {
      var thiz = this;
      this.selected_year = 2013;
      this.setYear = function(year) {
          if ( year !== this.selected_year ) {
              this.selected_year = year;
              this.selected_item = null;
              console.log("selected_year = "+year);
              this.fetchMatches();
          }
      };

      this.selected_level = 6;
      this.setLevel = function(level) {
          this.selected_level = level;
      };

      this.selected_kind = "";
      this.setKind = function(kind) {
          this.selected_kind = kind;
      };

      this.selected_item = null;
      this.curated_net_allocated = 0;
      this.curated_net_revised = 0;
      this.curated_net_used = 0;
      this.setItem = function(item) {
          if (thiz.selected_item === item) {
              item = null;
          }
          thiz.selected_item = item;
          thiz.query = "";
          thiz.results = [];
          thiz.inspected_item = null;
          thiz.inspected_item_kids = null;
          thiz.selected_item_relatives = null;
          if ( item !== null ) {
              item.breadcrumbs = [];
              thiz.fetchBreadcrumbs(item);
              item.curated = [];
              if ( item.match_status && item.match_status.curated && item.match_status.curated.length>0 ) {
                  for ( var _curatedCode = 0 ; _curatedCode < item.match_status.curated.length ; _curatedCode++ ) {
                      thiz.fetchCuratedItem(item.match_status.curated[_curatedCode]);
                  }
              }
          }
          if ( item !== null ) {
              var year = item.year;
              var code = item.code;
              $http.get('http://www.obudget.org/api/budget/'+code+'/'+year+'/matches')
                   .then(function(resp) {
                       var data = resp.data[0];
                       if ( data.year === thiz.selected_item.year &&
                            data.code === thiz.selected_item.code ) {
                            for ( var k in data ) {
                                thiz.selected_item[k] = data[k];
                            }
                            thiz.calcKind(thiz.selected_item);
                            if ( data.match_status.invalid && data.match_status.invalid.length > 0 ) {
                                data.match_status.invalid = data.match_status.invalid.filter(function(a, b, c) {
                                    return c.indexOf(a) === b;
                                });
                            }
                        }
                   });
              thiz.query = item.title;
              thiz.fetchResults();
          }

      };
      this.selected_item_relatives = null;
      this.fetchSiblings = function() {
          var code = thiz.selected_item.code;
          code = code.substring(0,code.length-2);
          $http.get('http://www.obudget.org/api/budget/'+code+'/'+thiz.selected_year+'/active-kids')
               .then(data(thiz.setRelatives));
      };
      this.fetchKids = function() {
          var code = thiz.selected_item.code;
          $http.get('http://www.obudget.org/api/budget/'+code+'/'+thiz.selected_year+'/active-kids')
               .then(data(thiz.setRelatives));
      };
      this.setRelatives = function(relatives) {
          thiz.selected_item_relatives = relatives;
      };


      this.fetchCuratedItem = function(code) {
          var success = function(response) {
              var fetchedItem = response.data;
              thiz.removeCuratedItem(fetchedItem);
              thiz.selected_item.curated.push(fetchedItem);
              thiz.updateCuratedSums();
              fetchedItem.breadcrumbs = [];
              thiz.fetchBreadcrumbs(fetchedItem);
          };
          $http.get('http://www.obudget.org/api/budget/'+code+"/"+(thiz.selected_item.year-1))
               .then(success);
      };
      this.removeCuratedItem = function(item) {
          var newCurated = [];
          for ( var _ci = 0 ; _ci < thiz.selected_item.curated.length ; _ci++ ) {
              var ci = thiz.selected_item.curated[_ci];
              if ( ci.code !== item.code ) {
                  newCurated.push(ci);
              }
          }
          thiz.selected_item.curated = newCurated;
          thiz.updateCuratedSums();
      };
      this.addCuratedItem = function(item) {
          thiz.fetchCuratedItem(item.code);
      };
      this.updateCuratedSums = function() {
          thiz.curated_net_allocated = 0;
          thiz.curated_net_revised = 0;
          thiz.curated_net_used = 0;
          for ( var _ci = 0 ; _ci < thiz.selected_item.curated.length ; _ci++ ) {
              var ci = thiz.selected_item.curated[_ci];
              thiz.curated_net_allocated += ci.net_allocated;
              thiz.curated_net_revised += ci.net_revised;
              thiz.curated_net_used += ci.net_used;
          }
      };
      this.fetchBreadcrumbs = function(item) {
          var success = function(response) {
              var parent = response.data;
              item.breadcrumbs.push(parent);
          };
          for ( var i = item.code.length-2 ; i > 2 ; i-=2) {
              $http.get('http://www.obudget.org/api/budget/'+item.code.substring(0,i)+"/"+item.year)
                   .then(success);
          }
      };

      this.calcKind = function(item) {
          var kind = null;
          if ( item.match_status.invalid && item.match_status.invalid.length>0 ) {
              kind = "invalid";
          } else if ( item.match_status.missing ) {
              kind = "missing";
          } else if ( item.match_status.heuristic && item.match_status.heuristic.length>0 ) {
              kind = "heuristic";
          } else if ( item.match_status.curated && item.match_status.curated.length>0) {
              kind = "curated";
          }
          item.match_kind = kind;
      };

      this.matches = [];
      this.kindCounts = {};
      this.curatedRev = {};
      this.addMatches = function(matches) {
          console.log("addMatches - " + matches.length + " : " + thiz.matches.length);
          for ( var _match = 0 ; _match < matches.length ; _match++ ) {
              var match = matches[_match];
              if ( match.year !== thiz.selected_year ) {
                  return;
              }
              thiz.matches.push(match);
              thiz.calcKind(match);
              var level = match.code.length - 2;
              if ( !thiz.kindCounts[level] )                   { thiz.kindCounts[level] = {}; }
              if ( !thiz.kindCounts[level][match.match_kind] ) { thiz.kindCounts[level][match.match_kind] = 0; }
              if ( !thiz.kindCounts[level][""] )               { thiz.kindCounts[level][""] = 0; }
              thiz.kindCounts[level][match.match_kind] += 1;
              thiz.kindCounts[level][""] += 1;
              if ( match.match_status.curated ) {
                  var curated = match.match_status.curated;
                  for ( var _ci = 0 ; _ci<curated.length ; _ci++ ) {
                      var ci = curated[_ci];
                      if ( !thiz.curatedRev[level] )     { thiz.curatedRev[level] = {}; }
                      if ( !thiz.curatedRev[level][ci] ) { thiz.curatedRev[level][ci] = []; }
                      thiz.curatedRev[level][ci].push(match);
                  }
              }
          }
          thiz.selected_item = null;
      };
      this.fetchMatches = function() {
          thiz.matches = [];
          thiz.curatedRev = {};
          thiz.kindCounts = {
              invalid: 0,
              curated: 0,
              heuristic: 0,
              missing: 0,
              "": 0
          };
          $http.get('http://www.obudget.org/api/budget/00/'+this.selected_year+"/matches",{params:{limit:10001},responseType:'json'})
               .then(data(thiz.addMatches));
      };
      this.getCuratedRev = function(code) {
          return thiz.curatedRev[thiz.selected_level][code];
      };

      this.query = "";
      this.resuts = [];
      this.fetchResults = function() {
          if (thiz.query.length > 2) {
              $http.get('http://www.obudget.org/api/search/full_text?q='+thiz.query+'&limit=100&types=BudgetLine&year='+(thiz.selected_year-1))
                   .then(data(thiz.setResults));
          } else {
              thiz.setResults([]);
          }
      };
      this.setResults = function(results) {
          for ( var i = 0 ; i < results.length ; i++ ) {
              if (!results[i].real_code) {
                  results[i].real_code = results[i].code.substring(2);
              }
          }
          thiz.results = results;
      };

      this.inspected_item = null;
      this.inspected_item_kids = null;
      this.inspectItem = function(code,year) {
          $http.get('http://www.obudget.org/api/budget/00'+code+'/'+year)
               .then(data(thiz.setInspectedItem));
          $http.get('http://www.obudget.org/api/budget/00'+code+'/'+year+'/active-kids')
               .then(data(thiz.setInspectedItemKids));
      };
      this.setInspectedItem = function(item) {
          thiz.inspected_item = item;
          item.breadcrumbs = [];
          thiz.fetchBreadcrumbs(item);
      };
      this.setInspectedItemKids = function(kids) {
          thiz.inspected_item_kids = kids;
      };
      this.clearInspectedItem = function() {
          thiz.inspected_item = null;
          thiz.inspected_item_kids = null;
      };

      this.save = function(what) {
          var fail = function() {
              $window.alert("לא ניתן לבצע את הפעולה :-(");
          };
          var success = function(response) {
              var data = response.data;
              if ( data.OK ) {
                  $window.alert("תודה רבה, הנתונים יתעדכנו בשעה הקרובה");
                  thiz.selected_item.match_status.missing = false;
                  var curated = [];
                  for ( var _ci = 0 ; _ci < thiz.selected_item.curated.length ; _ci++ ) {
                      curated.push(thiz.selected_item.curated[_ci].code);
                  }
                  thiz.selected_item.match_status.curated = curated;
                  thiz.calcKind(thiz.selected_item);
                  thiz.setItem(null);
              } else {
                  fail();
              }
          };
          $http.post("http://www.obudget.org/api/budget-matches",what)
               .then(success,fail);
      };

      this.username = null;
      this.url = null;
      this.greeting = function() {
          var success = function(response) {
              var data = response.data;
              thiz.username = data.username;
              thiz.url = data.url;
          };
          $http.post("http://www.obudget.org/api/budget-matches",{})
               .then(success);
      };

      this.stats = {};
      this.fetchStats = function() {
          var success = function(response) {
              thiz.stats = response.data.value;
          };
          $http.get("http://www.obudget.org/api/sysprop/match-stats").then(success);
      };

      this.greeting();
      this.fetchMatches();
      this.fetchStats();
  }]);
