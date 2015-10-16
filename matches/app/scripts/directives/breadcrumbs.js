"use strict";

angular.module('matchesApp')
.directive("itemBreadcrumbs", function() {
    return {
      restrict: 'E',
      templateUrl: "views/item-breadcrumbs.html",
      scope: {
          item: '=bitem',
      },
      controller: [ "$http", "$scope", function($http,$scope) {
          this.item = $scope.item;
      }],
      controllerAs:'breadcrumbs'
    };
  });
