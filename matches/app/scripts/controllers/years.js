'use strict';

/**
 * @ngdoc function
 * @name matchesApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the matchesApp
 */
angular.module('matchesApp')
  .controller('YearController', [ function () {

      var FIRST1 = 1993;
      var FIRST2 = 2005;
      this.years=[];
      this.firstYear = FIRST2;
      this.show = true;
      var thiz = this;

      this.toggle = function() {
          thiz.firstYear = FIRST1 + FIRST2 - thiz.firstYear;
          thiz.show = !thiz.show;
          thiz.setYears();
      };

      this.setYears = function() {
          thiz.years = [];
          for ( var i = thiz.firstYear ; i < 2017 ; i++ ) {
              thiz.years.push(i);
          }
      };

      this.setYears();
 }]);
