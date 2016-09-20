'use strict';

angular.module('journals.currentDate', []).
  factory('currentDate', function () {
    var testMode = angular.element('body').hasClass('test');

    function ordinalize(x) {
      if (x > 3 && x < 21) return 'th';

      switch (x % 10) {
        case 1:  return "st";
        case 2:  return "nd";
        case 3:  return "rd";
        default: return "th";
      }
    }

    var currentDate = {
      get: function () {
        // If we're running tests, freeze the date at 20th July, 2013
        if (testMode) {
          return new Date(2014, 6, 20);
        }

        return new Date();
      },
      getLong: function () {
        var date, day, formattedDate;
        date = currentDate.get();
        day = date.getDate();
        formattedDate = jQuery.datepicker.formatDate(' MM yy', date);
        return day + ordinalize(day) + formattedDate;
      }
    };

    return currentDate;
  });