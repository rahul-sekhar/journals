'use strict';

angular.module('journals.arrayExtensions', []).
  config(function() {
    Array.prototype.replace = function(source) {
      this.length = 0;
      for (var i = 0; i < source.length; i++) {
        this.push(source[i]);
      }
    };

    Array.prototype.remove = function(value) {
      var index = this.indexOf(value);
      if (index > -1) {
        this.splice(index, 1);
        return true;
      }
      else {
        return false;
      }
    };
  });