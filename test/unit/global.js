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

    assets.preload = function () {};

    return assets;
  });

// Replace confirm module
angular.module('journals.confirm', []).

  factory('confirm', function() {
    var ret = true;

    var confirm = jasmine.createSpy().andCallFake(function() {
      return ret;
    });

    confirm.set = function(val) {
      ret = val;
    };

    return confirm;
  });

/*-------------- Pending tests -------------------------*/
// editInPlace directive - date field
// onType directive
// pagination directive
// modal directive
// helpers module
// filteredList directive