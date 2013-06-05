'use strict';

/* Filters */

angular.module('journals.filters', []).

  filter('capitalize', function () {
    return function (text) {
      var wordArray = String(text).replace(/_/g, ' ').split(' ');
      wordArray = wordArray.map(function (word) {
        var lineArray = word.split("\n");
        lineArray = lineArray.map(function (line) {
          return line.substring(0, 1).toUpperCase() + line.substring(1);
        });
        return lineArray.join("\n");
      });
      return wordArray.join(' ');
    };
  }).

  filter('multiline', function () {
    return function (text) {
      if (!text) {
        return null;
      }
      return text.replace(/\n/g, '<br />');
    };
  }).

  filter('escapeHtml', function () {
    return function (text) {
      if (!text) {
        return null;
      }
      return String(text)
        .replace(/&/g, '&amp;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');
    };
  }).

  filter('filterDeleted', function () {
    return function (array) {
      if (!array) {
        return null;
      }
      return array.filter(function (object) {
        return !object.deleted;
      });
    };
  }).

  // This filter applies a filter depending on the argument given to it
  filter('apply', ['$injector', function ($injector) {
    return function (text, filterName) {
      if (!filterName) {
        return text;
      }
      var filter = $injector.get(filterName + 'Filter');
      return filter(text);
    };
  }]).

  filter('blankDate', function () {
    return function (text) {
      if (!text) {
        return '\u2014';
      }
      return text;
    };
  }).

  /**
   * Truncate Filter
   * @Param text
   * @Param length, default is 10
   * @Param end, default is "..."
   * @return string
   */
  filter('truncate', function () {
    return function (text, length, end) {
      if (isNaN(length))
        length = 10;

      if (end === undefined)
        end = "...";

      if (text.length <= length || text.length - end.length <= length) {
        return text;
      }
      else {
        return String(text).substring(0, length-end.length) + end;
      }
    };
  }).

  /*
   * http://stackoverflow.com/questions/11873570/angularjs-for-loop-with-numbers-ranges
   */
  filter('range', function() {
    return function(input, total) {
      total = parseInt(total);
      for (var i=0; i<total; i++)
        input.push(i);
      return input;
    };
  });
