'use strict';

angular.module('journals.editInPlace', ['ngSanitize', 'journals.filters', 'journals.directives'])
  .directive('editInPlace', ['$compile', '$timeout', function ($compile, $timeout) {
    return {
      restrict: 'A',
      scope: {
        instance: '=',
        field: '@',
        type: '@',
        editMode: '=?',
        placeholder: '@',
        noAge: '@',
        blankDate: '@'
      },
      template:
        '<span class="container">' +
          '<span class="value" ng-bind-html="instance[field] | escapeHtml | apply:filter" ng-hide="editMode" ng-click="startEdit()"></span>' +
        '</span>',
      controller: 'editInPlaceCtrl',
      link: function (scope, elem, attrs) {

        if (attrs.noClickEdit !== undefined) {
          scope.noClickEdit = true;
        }

        // Compile the inputs on the fly because we don't expect 'type' to change once it is set
        // If changes are expected, add a compile step to sort out possible performance issues
        scope.$watch('type', function (val) {
          var input, clearLink, dateSetPromise;

          // Change the input and filter depending on type
          if (val === undefined || val === null || val === 'text' || val === 'date') {
            input = angular.element('<input class="editor" placeholder="{{placeholder}}" ng-show="editMode" focus-on="editMode" ng-model="editorValue" />');
            scope.filter = null;
            if (val === 'date' && !scope.noAge) {
              scope.filter = 'dateWithAge';
            } else if (scope.blankDate) {
              scope.filter = 'blankDate';
            }

          } else if (val === 'textarea') {
            input = angular.element('<textarea class="editor" placeholder="{{placeholder}}" ng-show="editMode" focus-on="editMode" ng-model="editorValue"></textarea>');
            scope.filter = 'multiline';

          } else {
            throw new Error('editInPlace type not recognized - ' + val);
          }

          $compile(input)(scope);
          elem.find('.editor, .clear-date').remove();
          input.appendTo(elem.find('.container'));

          if (val === 'date') {
            clearLink = angular.element('<a href="" class="clear-date" ng-click="clearDate()" ng-show="editMode"' +
              'ng-mouseenter="clearHover = true" ng-mouseleave="clearHover = false"></a>');
            $compile(clearLink)(scope);
            clearLink.appendTo(elem.find('.container'));

            input.datepicker({
              dateFormat: 'dd-mm-yy',
              changeMonth: true,
              changeYear: true,
              yearRange: '-30:+0',
              onClose: function (date) {
                // Make a blank date null
                if (date === '') { date = null };

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

            // Prevent datepicker clicks from propagating
            input.datepicker('widget').bind('click', function(event) {
              event.stopPropagation();
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
      if (!$scope.noClickEdit) {
        $scope.editMode = true;
      }
    };

    $scope.$watch('instance._edit', function(value) {
      if (value && $scope.instance.isNew() && value === $scope.field) {
        $scope.editMode = true;
      }
    });

    $scope.$watch('editMode', function (value) {
      if (value) {
        $scope.editorValue = $scope.instance[$scope.field];
      }
    });

    $scope.finishEdit = function () {
      $scope.instance.updateField($scope.field, $scope.editorValue);
      $scope.editMode = false;
    };

    $scope.cancelEdit = function () {
      $scope.editMode = false;
    };

    $scope.clearEdit = function () {
      $scope.instance.updateField($scope.field, null);
      $scope.editMode = false;
    };
  }]).

  controller('EditObjectCtrl', ['$scope', function ($scope) {
    $scope.editing = {};
  }]);