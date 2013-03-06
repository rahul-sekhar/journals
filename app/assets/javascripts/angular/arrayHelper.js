'use strict';

angular.module('journals.arrayHelper', []).
  factory('arrayHelper', function() {
    var arrayHelper = {};

    arrayHelper.shallowCopy = function(source, dest) {
      dest.length = 0;
      for (var i = 0; i < source.length; i++) {
        dest.push(source[i]);
      }
    };

    arrayHelper.removeItem = function(source, item) {
      var index = source.indexOf(item);
      if (index > -1) {
        source.splice(index, 1);
        return true;
      }
      else {
        return false;
      }
    };

    return arrayHelper;
  });
