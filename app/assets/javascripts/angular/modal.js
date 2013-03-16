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
          width: attrs.modalWidth || 300,
          show: 300,
          hide: 300,
          close: function () {
            scope.$apply(function() {
              scope.showOn = false;
            });
          }
        });
        scope.$watch('showOn', function (val) {
          if (val) {
            elem.dialog('open');
          }
          else {
            elem.dialog('close');
          }
        });
      }
    };
  });