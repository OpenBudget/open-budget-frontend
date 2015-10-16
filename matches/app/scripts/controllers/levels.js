'use strict';

/**
 * @ngdoc function
 * @name matchesApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the matchesApp
 */
angular.module('matchesApp')
  .controller('LevelController', [ function () {
    this.levels=[
        {level:2, name:"סעיפים"},
        {level:4, name:"תחומי פעולה"},
        {level:6, name:"תכניות"},
        {level:8, name:"תקנות"}
    ];
 }]);
