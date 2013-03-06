'use strict';

beforeEach(function() {
  this.addMatchers({
    toEqualData: function(expected) {
      return angular.equals(this.actual, expected);
    },
    toEqualArrayData: function(expected) {
      return $(this.actual).not(expected).length == 0 && $(expected).not(this.actual).length == 0
    }
  });
});

// Replace assets module
angular.module('journals.assets', []).

  factory('assets', function() {
    var assets = {};

    assets.url = function(filename) {
      return 'http://localhost:3000/assets/' + filename
    };

    return assets;
  });

/*-------------- Pending tests -------------------------*/
// editInPlace directive - date field
// onType directive
// pagination directive
// modals directive
// arrayExtensions module
// filteredList directive