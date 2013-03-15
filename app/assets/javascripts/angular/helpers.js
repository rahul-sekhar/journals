'use strict';

angular.module('journals.helpers', []).
  factory('arrayHelper', function () {
    var arrayHelper = {}, i;

    arrayHelper.shallowCopy = function (source, dest) {
      dest.length = 0;
      for (i = 0; i < source.length; i += 1) {
        dest.push(source[i]);
      }
    };

    arrayHelper.removeItem = function (source, item) {
      var index = source.indexOf(item);
      if (index > -1) {
        source.splice(index, 1);
        return true;
      }
      return false;
    };

    arrayHelper.difference = function (arrayHelper1, arrayHelper2) {
      return arrayHelper1.slice(0).filter(function (x) {
        return (arrayHelper2.slice(0).indexOf(x) < 0);
      });
    };

    arrayHelper.replace = function (source, oldItem, newItem) {
      var index = source.indexOf(oldItem);
      source[index] = newItem;
    };

    return arrayHelper;
  }).

  factory('objectHelper', function () {
    var objectHelper = {};

    objectHelper.shallowCopy = function (source, dest) {
      var key;

      angular.forEach(dest, function (value, key) {
        delete dest[key];
      });
      for (key in source) {
        dest[key] = source[key];
      }
    };

    return objectHelper;
  });
