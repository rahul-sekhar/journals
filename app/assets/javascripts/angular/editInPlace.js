'use strict';

angular.module('journals.editInPlace', ['ngSanitize', 'journals.filters'])
  .directive('editInPlace', ['$compile', '$timeout', function ($compile, $timeout) {
    return {
      restrict: 'A',
      scope: {
        saveFn: '&editInPlace',
        parentValue: '=editorAttr',
        type: '@',
        display: '@',
        editMode: '='
      },
      template:
        '<span class="container">' +
          '<span class="value" ng-bind-html="display | apply:conditionalEscapeHtml" ng-hide="editMode" ng-click="startEdit()"></span>' +
        '</span>',
      controller: 'editInPlaceCtrl',
      link: function (scope, elem, attrs) {
        // Escape HTML unless a contains-html attribute is present
        if (attrs.containsHtml === undefined) {
          scope.conditionalEscapeHtml = 'escapeHtml';
        } else {
          scope.conditionalEscapeHtml = null;
        }

        // Compile the inputs on the fly because we don't expect 'type' to change once it is set
        // If changes are expected, add a compile step to sort out possible performance issues
        scope.$watch('type', function (val) {
          var input, clearLink, dateSetPromise;

          // Text input
          if (val === undefined || val === null || val === 'text' || val === 'date') {
            input = angular.element('<input class="editor" ng-show="editMode" focus-on="editMode" ng-model="editorValue" />');
          } else if (val === 'textarea') {
            input = angular.element('<textarea class="editor" ng-show="editMode" focus-on="editMode" ng-model="editorValue"></textarea>');
          } else {
            throw new Error('editInPlace type not recognized - ' + val);
          }

          $compile(input)(scope);
          elem.find('.editor, .clear-date').remove();
          input.appendTo(elem.find('.container'));

          if (val === 'date') {
            clearLink = angular.element('<a href="" class="clear-date" ng-click="clearDate()" ng-show="editMode"' +
              'ng-mouseenter="clearHover = true" ng-mouseleave="clearHover = false">clear</a>');
            $compile(clearLink)(scope);
            clearLink.appendTo(elem.find('.container'));

            input.datepicker({
              dateFormat: 'dd-mm-yy',
              changeMonth: true,
              changeYear: true,
              yearRange: '-30:+0',
              onClose: function (date) {
                scope.$apply(function () {
                  // If the mouse is hovering over the clear button, give the user time to click it
                  if (!scope.clearHover) {
                    scope.editorValue = date;
                    scope.finishEdit();
                  } else {
                    dateSetPromise = $timeout(function () {
                      scope.editorValue = date;
                      scope.finishEdit();
                    }, 500);
                  }
                });
              }
            });

            scope.clearDate = function () {
              $timeout.cancel(dateSetPromise);
              scope.clearEdit();
            };
          } else {
            input.
              on('blur', function () {
                scope.$apply(scope.finishEdit);
              }).
              on('keydown', function (e) {
                if (e.keyCode === 13 && input.is(':not(textarea)')) {
                  // Enter key (do not check for textareas)
                  scope.$apply(scope.finishEdit);
                } else if (e.keyCode === 27) {
                  // Escape key
                  scope.$apply(scope.cancelEdit);
                }
              });
          }
        });
      }
    };
  }])

  .controller('editInPlaceCtrl', ['$scope', function ($scope) {
    $scope.startEdit = function () {
      $scope.editMode = true;
    };

    $scope.$watch('editMode', function (value) {
      if (value) {
        $scope.editorValue = $scope.parentValue;
      }
    });

    $scope.finishEdit = function () {
      $scope.saveFn({value: $scope.editorValue});
      $scope.editMode = false;
    };

    $scope.cancelEdit = function () {
      $scope.editMode = false;
    };

    $scope.clearEdit = function () {
      $scope.saveFn({value: null});
      $scope.editMode = false;
    };
  }]).

  directive('focusOn', ['$timeout', function ($timeout) {
    return function (scope, elem, attrs) {
      scope.$watch(attrs.focusOn, function (value) {
        if (value) {
          $timeout(function () {
            elem.focus();
          }, 10);
        }
      });
    };
  }]);