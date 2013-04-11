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
          var i, url, startVal, endVal;

          elem.empty();
          if (scope.currentPage) {
            if (scope.currentPage > 1) {
              elem.append('<a href="" data-page="1">&laquo; First</a>');
              elem.append('<a href="" data-page="' + (scope.currentPage - 1) + '">&lsaquo; Prev</a>');
            }

            startVal = Math.max(1, Math.min(scope.currentPage - 2, scope.totalPages - 4))
            endVal = Math.min(scope.totalPages, startVal + 4)
            for (i = startVal; i <= endVal; i += 1) {
              if (i === scope.currentPage) {
                elem.append('<span class="current"> ' + i + ' </span> ');
              } else {
                elem.append('<a href="" data-page="' + i + '"> ' + i + ' </a>');
              }
            }

            if (scope.currentPage < scope.totalPages) {
              elem.append('<a href="" data-page="' + (scope.currentPage + 1) + '">Next &rsaquo;</a>');
              elem.append('<a href="" data-page="' + scope.totalPages + '">Last &raquo;</a>');
            }
          }
          elem.on('click', 'a', function(e) {
            scope.$apply(function() {
              scope.changePage($(e.target).data('page'));
            });
          });
        };

        scope.$watch('totalPages', updateFn);
        scope.$watch('currentPage', updateFn);
      },
      controller: 'PaginationCtrl'
    };
  }]).

  controller('PaginationCtrl', ['$scope', '$location', '$rootScope', function ($scope, $location, $rootScope) {
    $scope.changePage = function(page) {
      var topPos, deregister;

      $location.search('page', page);

      deregister = $rootScope.$on('loaded', function () {
        $('body').scrollTop($('#main-content').offset().top);
        deregister();
      });
    };
  }]);