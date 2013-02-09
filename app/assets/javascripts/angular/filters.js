'use strict';

/* Filters */

angular.module('journalsApp.filters', []).
  filter('capitalize', function() {
    return function(text) {
      var wordArray = String(text).replace(/_/g, ' ').split(' ');
      var capitalizedArray = [];
      $.each(wordArray, function() {
        capitalizedArray.push( this.substring(0, 1).toUpperCase() + this.substring(1) );
      });
      return capitalizedArray.join(' ');
    }
  });
