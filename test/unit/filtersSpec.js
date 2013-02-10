'use strict';

describe('filter', function() {
  beforeEach(module('journalsApp.services'));
  beforeEach(module('journalsApp.filters'));


  describe('capitalize', function() {
    it('should capitalize each word of a passed string', inject(function(capitalizeFilter) {
      expect(capitalizeFilter('some text')).toEqual('Some Text');
    }));

    it('should replace underscores with spaces and then capitalize each word', inject(function(capitalizeFilter) {
      expect(capitalizeFilter('some_other_text')).toEqual('Some Other Text');
    }));
  });

  describe('simpleSingularize', function() {
    it('leaves the word alone if the last character is not an s', inject(function(simpleSingularizeFilter) {
      expect(simpleSingularizeFilter('thing')).toEqual('thing');
    }));

    it('removes the last character if it is an s', inject(function(simpleSingularizeFilter) {
      expect(simpleSingularizeFilter('things')).toEqual('thing');
    }));
  });

  describe('simpleFormat', function() {
    it('replaces new lines with brs', inject(function(simpleFormatFilter) {
      expect(simpleFormatFilter("Some thing\non many\nlines")).toEqual('Some thing<br />on many<br />lines');
    }));

    it('leaves single line values alone', inject(function(simpleFormatFilter) {
      expect(simpleFormatFilter('Some thing on one line')).toEqual('Some thing on one line');
    }));

    it('returns null for a null value', inject(function(simpleFormatFilter) {
      expect(simpleFormatFilter(null)).toEqual(null);
    }));
  });

  describe('dateToAge', function() {
    var currentDateMock

    beforeEach(function() {
      module(function($provide) {
        currentDateMock = {
          get: function() {
            return new Date('2013-01-01')
          }
        };
        $provide.value('currentDate', currentDateMock)
      });
    });

    it('converts a date to an age', inject(function(dateToAgeFilter) {
      expect(dateToAgeFilter('24-04-2007')).toEqual(5);
    }));

    it('returns null for a null date', inject(function(dateToAgeFilter) {
      expect(dateToAgeFilter(null)).toEqual(null);
    }));
  });
});
