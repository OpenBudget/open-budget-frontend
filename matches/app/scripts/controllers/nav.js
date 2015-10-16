'use strict';

/**
 * @ngdoc function
 * @name matchesApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the matchesApp
 */
angular.module('matchesApp')
  .controller('NavController', [ '$rootScope', function ($rootScope) {
      this.about = false;
      var thiz = this;
      $rootScope.$on( "$routeChangeSuccess", function(event, next /*, current*/) {
          thiz.about = next.$$route.controllerAs === 'about';
      });
 }]);
