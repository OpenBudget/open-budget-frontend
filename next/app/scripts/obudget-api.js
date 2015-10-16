'use strict';

var obudgetServices = angular.module('obudgetServices', ['ngResource']);

var BASE="http://www.obudget.org/api";

obudgetServices.factory('obudgetAPI', ['$resource',
  function($resource){
      return {
            Base: BASE,
            Budget: $resource(BASE+'/budget/:code/:year/:modifier/:depth',{})
            // modifier: equivs, kids, active-kids, parents, matches, depth


      };
}]);
