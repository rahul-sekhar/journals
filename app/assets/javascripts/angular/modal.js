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
          minWidth: attrs.modalWidth || 300,
          minHeight: attrs.modalHeight || 100,
          resizable: !!attrs.resizable || false,
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