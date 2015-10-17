'use strict';

var obudgetServices = angular.module('obudgetServices', ['ngResource']);

var BASE="http://www.obudget.org/api";

obudgetServices.factory('obudgetAPI', ['$resource','$http',
  function($resource,$http){
      return {
            Base: BASE,
            Budget: $resource(BASE+'/budget/:code/:year/:modifier/:depth',{}),
            FulltextSearch: $resource(BASE+'/search/full_text', {})
            // modifier: equivs, kids, active-kids, parents, matches, depth
      };
}]);
