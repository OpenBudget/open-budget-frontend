'use strict';

/**
 * @ngdoc function
 * @name nextApp.controller:SearchCtrl
 * @description
 * # SearchCtrl
 * Controller of the nextApp
 */
angular.module('obudget')
  .controller('SearchCtrl', ['obudgetAPI', function (obudgetAPI) {
    this.search = function(query) {
      this.results = obudgetAPI.FulltextSearch.query({q:query});
    };


    this.a = 'sdfsdf';
  }]);
