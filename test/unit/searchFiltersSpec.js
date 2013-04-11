describe('searchFilters module', function () {
  beforeEach(module('journals.searchFilters'));

  describe('searchFilters', function () {
    var searchFilters, location;

    beforeEach(inject(function (_searchFilters_, $location) {
      location = $location;

      searchFilters = _searchFilters_(['param1', 'param2', 'param3'], ['param4', 'param5'], 'param6');
    }));

    describe('filter(param, value)', function () {
      it('throws an error if the param was not passed', function () {
        expect(function () {
          searchFilters.filter('param7', 'someval')
        }).toThrow('Filter param7 was not initialized');
      });

      it('changes location search to match the filter value', function () {
        searchFilters.filter('param2', 'value');
        expect(location.search()).toEqualData({ param2: 'value' });
      });

      it('works for filters that were passed as a single value rather than array', function () {
        searchFilters.filter('param6', 'other value');
        expect(location.search()).toEqualData({ param6: 'other value' });
      });

      it('removes any other parameter that was not initialized', function () {
        location.search({ some_param: 'some_val' });
        searchFilters.filter('param2', 'value');
        expect(location.search()).toEqualData({ param2: 'value' });
      });

      it('removes parameters not contained in the passed params group', function () {
        location.search({ param4: 'value', param6: 'val' });
        searchFilters.filter('param2', 'value');
        expect(location.search()).toEqualData({ param2: 'value' });
      });

      it('does not remove paramaters of the same group', function () {
        location.search({ param3: 'other val' });
        searchFilters.filter('param2', 'value');
        expect(location.search()).toEqualData({ param2: 'value', param3: 'other val' });
      });

      it('removes all unlinked params and keeps all linked ones', function () {
        location.search({ param3: 'other val', param6: 'asdf', param1: 'abc', blah: 'gah' });
        searchFilters.filter('param2', 'value');
        expect(location.search()).toEqualData({ param2: 'value', param3: 'other val', param1: 'abc' });
      });
    });

    describe('getCurrentValues()', function () {
      it('returns the current values of each filter param', function () {
        location.search({
          param1: 'val1', param2: 'val2', param5: 'val3', param6: 'val4', param7: 'val5', otherParam: 'val6'
        });

        expect(searchFilters.getCurrentValues()).toEqualData({
          param1: 'val1', param2: 'val2', param5: 'val3', param6: 'val4'
        });
      });
    });
  });
});