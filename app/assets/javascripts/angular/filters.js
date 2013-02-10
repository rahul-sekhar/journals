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
    };
  }).
  
  filter('simpleSingularize', function() {
    return function(text) {
      var lastChar = text.substr(-1)
      if (lastChar == 's' || lastChar == 'S') {
        return text.slice(0, -1);
      }
      else {
        return text;
      }
    };
  }).

  filter('dateToAge', function(currentDate) {
    return function(date_text) {
      if (!date_text) return null;

      var birthDate = $.datepicker.parseDate('dd-mm-yy', date_text);
      var currDate = currentDate.get();

      var age = currDate.getFullYear() - birthDate.getFullYear();
      var m = currDate.getMonth() - birthDate.getMonth();
      if (m < 0 || (m === 0 && currDate.getDate() < birthDate.getDate())) {
        age--;
      }
      return age;
    };
  });
