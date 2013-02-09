'use strict';

describe('filter', function() {
  beforeEach(module('journalsApp.filters'));


  describe('capitalize', function() {
    it('should capitalize each word of a passed string', inject(function(capitalizeFilter) {
      expect(capitalizeFilter('some text')).toEqual('Some Text');
    }));

    it('should replace underscores with spaces and then capitalize each word', inject(function(capitalizeFilter) {
      expect(capitalizeFilter('some_other_text')).toEqual('Some Other Text');
    }));
  });
});
