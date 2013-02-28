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