'use strict';

/**
 * @ngdoc function
 * @name matchesApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the matchesApp
 */
angular.module('matchesApp')
  .controller('KindController', [ function () {
    this.kinds=[
        {kind:"", name:"הצג הכל"},
        {kind:"invalid", name:"שגיאות בהתאמה"},
        {kind:"missing", name:"התאמות חסרות"},
        {kind:"curated", name:"התאמות ידניות"},
        {kind:"heuristic", name:"התאמות משוערות"}
    ];
 }]);
