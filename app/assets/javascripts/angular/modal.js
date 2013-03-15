'use strict';

angular.module('journals.modal', []).

  directive('modal', function () {
    return {
      restrict: 'E',
      transclude: true,
      scope: {
        showOn: '='
      },
      template:
        '<div class="modal" ng-transclude>' +
        '</div>',
      replace: true,
      link: function (scope, elem, attrs) {
        elem.dialog({
          autoOpen: false,
          modal: true,
          show: 300,
          hide: 300,
          close: function () {
            scope.showOn = false;
            scope.$apply();
          }
        });
        scope.$watch('showOn', function (val) {
          if (val) {
            elem.dialog('open');
          }
        });
      }
    };
  });