'use strict';

/**
 * @ngdoc function
 * @name nextApp.controller:AboutCtrl
 * @description
 * # AboutCtrl
 * Controller of the nextApp
 */
angular.module('obudget')
  .controller('AboutCtrl', ["obudgetAPI", function (obudgetAPI) {
    this.education = obudgetAPI.Budget.query({code: '0020'});
}]);
