'use strict';

angular.module('journals.currentDate', []).
  factory('currentDate', function() {
    return {
      get: function() {
        return new Date();
      }
    };
  });