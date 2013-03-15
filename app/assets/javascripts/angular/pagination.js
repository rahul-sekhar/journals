'use strict';

angular.module('journals.pagination', []).

  directive('pagination', ['$location', function ($location) {
    return {
      restrict: 'E',
      transclude: true,
      scope: {
        currentPage: '=',
        totalPages: '='
      },
      template:
        '<div id="pagination">' +
        '</div>',
      replace: true,
      link: function (scope, elem, attrs) {
        var updateFn = function () {
          var i, url;

          elem.empty();
          if (scope.currentPage) {
            for (i = 1; i <= scope.totalPages; i += 1) {
              if (i === scope.currentPage) {
                elem.append('<span class="current"> ' + i + ' </span> ');
              } else {
                url = $location.path() + '?' + $.param({page: i});
                elem.append('<a href="' + url + '"> ' + i + ' </a>');
              }
            }
          }
        };

        scope.$watch('totalPages', updateFn);
        scope.$watch('currentPage', updateFn);
      }
    };
  }]);