'use strict';

angular.module('journals.confirm', []).
  
  factory('confirm', ['$window', function($window) {
    return function(message) {
      return $window.confirm(message);
    };
  }]);