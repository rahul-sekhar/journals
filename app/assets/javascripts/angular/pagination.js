'use strict';

angular.module('journals.pagination', []).
  
  directive('pagination', function($location) {
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
      link: function(scope, elem, attrs) {
        var update = function() {
          elem.empty();
          if(scope.currentPage) {
            for(var i = 1; i <= scope.totalPages; i++) {
              if(i == scope.currentPage) {
                elem.append('<span class="current"> ' + i + ' </span> ')
              }
              else {
                var url = $location.path() + '?' + $.param({page: i});
                elem.append('<a href="' + url + '"> ' + i + ' </a>');
              }
            }
          }
        }
        scope.$watch('totalPages', update);
        scope.$watch('currentPage', update);
      }
    };
  });