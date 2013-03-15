'use strict';

describe('general filters module', function() {
  beforeEach(module('journals.filters'));

  describe('apply', function() {
    it('should apply the passed filter', inject(function(applyFilter) {
      expect(applyFilter("some\ntext", 'capitalize')).toEqual("Some\nText");
      expect(applyFilter("some\ntext", 'multiline')).toEqual("some<br />text");
    }));

    it('should act as an identity filter if no filter is passed', inject(function(applyFilter) {
      expect(applyFilter("some\ntext", null)).toEqual("some\ntext");
    }));
  });

  describe('escapeHtml', function() {
    it('should escape html entities', inject(function(escapeHtmlFilter) {
      expect(escapeHtmlFilter("some<text")).toEqual("some&lt;text");
    }));

    it('returns null for a blank value', inject(function(escapeHtmlFilter) {
      expect(escapeHtmlFilter(null)).toEqual(null);
    }));
  });

  describe('capitalize', function() {
    it('should capitalize each word of a passed string', inject(function(capitalizeFilter) {
      expect(capitalizeFilter('some text')).toEqual('Some Text');
    }));

    it('should capitalize each word of a passed string with multiple lines', inject(function(capitalizeFilter) {
      expect(capitalizeFilter("some\nmultiline\ntext")).toEqual("Some\nMultiline\nText");
    }));

    it('should replace underscores with spaces and then capitalize each word', inject(function(capitalizeFilter) {
      expect(capitalizeFilter('some_other_text')).toEqual('Some Other Text');
    }));
  });

  describe('multiline', function() {
    it('replaces new lines with brs', inject(function(multilineFilter) {
      expect(multilineFilter("Some thing\non many\nlines")).toEqual('Some thing<br />on many<br />lines');
    }));

    it('leaves single line values alone', inject(function(multilineFilter) {
      expect(multilineFilter('Some thing on one line')).toEqual('Some thing on one line');
    }));

    it('returns null for a null value', inject(function(multilineFilter) {
      expect(multilineFilter(null)).toEqual(null);
    }));
  });

  describe('filterDeleted', function() {
    it('returns all members without the deleted key set', inject(function(filterDeletedFilter) {
      var input = [{id: 1}, {id: 2, deleted: true}, {id: 3, deleted: false}, {id: 4, deleted: 'yes'}, {id: 5}]
      var output = filterDeletedFilter(input);

      expect(output).toEqual([{id: 1}, {id: 3, deleted: false}, {id: 5}])
    }));

    it('returns an empty array for an undefined value', inject(function(filterDeletedFilter) {
      expect(filterDeletedFilter(null)).toEqual([]);
    }));
  })
});
