angular.module('journals.searchFilters', []).

  factory('searchFilters', ['$location', function ($location) {

    // Accepts filterGroups as arguments - arrays of filter names that are linked to each other.
    // Each group is considered independent of the other arguments passed
    return function () {
      var filterGroups, getGroup;

      filterGroups = arguments;

      getGroup = function (param) {
        var paramGroup;
        angular.forEach(filterGroups, function (group) {
          if ((group === param) || (group.indexOf(param) !== -1)) {
            paramGroup = group;
          }
        });
        return paramGroup;
      }

      return {
        filter: function (param, value) {
          var paramGroup, searchData = {}, currentParams;

          paramGroup = getGroup(param);

          if (!paramGroup) {
            throw new Error('Filter ' + param + ' was not initialized');
          }

          currentParams = $location.search();
          if (angular.isArray(paramGroup)) {
            angular.forEach (paramGroup, function (linkedParam) {
              if (currentParams[linkedParam]) {
                searchData[linkedParam] = currentParams[linkedParam];
              }
            });
          }
          if (value) {
            searchData[param] = value;
          } else if (searchData[param]) {
            delete searchData[param];
          }

          $location.search(searchData).replace();
        },

        getCurrentValues: function () {
          var currentVals = {}, params;
          params = $location.search();

          function addParam (param) {
            currentVals[param] = params[param];
          }

          angular.forEach(filterGroups, function (group) {
            if (angular.isArray(group)) {
              angular.forEach(group, addParam);
            } else {
              addParam(group);
            }
          });

          return currentVals;
        }
      };
    };
  }]);