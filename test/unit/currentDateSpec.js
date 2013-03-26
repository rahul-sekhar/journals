'use strict';

describe('currentDate module', function () {
  beforeEach(module('journals.currentDate'));

  describe('currentDate', function () {
    var currentDate;

    beforeEach(inject(function (_currentDate_) {
      currentDate = _currentDate_;
    }));

    describe('getLong()', function () {
      it('returns a long version of the current date', function () {
        currentDate.get = function () { return new Date(2011, 5, 2); };
        expect(currentDate.getLong()).toEqual('2nd June 2011');

        currentDate.get = function () { return new Date(1990, 2, 11); };
        expect(currentDate.getLong()).toEqual('11th March 1990');

        currentDate.get = function () { return new Date(2014, 0, 23); };
        expect(currentDate.getLong()).toEqual('23rd January 2014');
      });
    });
  });
});