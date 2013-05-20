'use strict';

angular.module('journals.directives', []).

  directive('filteredList', function () {
    return {
      restrict: 'E',
      scope: {
        list: '=',
        onSelect: '&',
        showProperty: '@',
        alwaysShown: '@'
      },
      template:
        '<div class="filtered-list" ng-show="list.length">' +
          '<div class="list" ng-show="alwaysShown || listShown">' +
            '<input ng-model="filter" focus-on="listShown" />' +
            '<ul>' +
              '<li ng-repeat="item in list | filter: filterObj | orderBy: showProperty" ng-animate="\'fade\'">' +
                '<a href="" ng-hide="item.deleted" internal-click="select(item)">{{item[showProperty]}}</a>' +
              '</li>' +
            '</ul>' +
          '</div>' +
          '<a class="add" ng-hide="alwaysShown" href="" internal-click="toggleList()" ng-class="{cancel: listShown}">{{buttonText}}</a>' +
        '</div>',
      controller: ['$scope', function ($scope) {
        $scope.filterObj = {};
        $scope.$watch('filter', function (value) {
          $scope.filterObj[$scope.showProperty] = value;
        });

        $scope.listShown = !!$scope.alwaysShown;

        $scope.toggleList = function () {
          $scope.listShown = !$scope.listShown;
        };

        $scope.$on('menuClosed', function() {
          $scope.listShown = false;
        });

        $scope.$watch('listShown', function (value) {
          $scope.buttonText = value ? "Cancel" : ($scope.addText || "Add");
        });

        $scope.select = function (item) {
          $scope.listShown = false;
          $scope.filter = '';
          $scope.onSelect({value: item});
        };
      }]
    };
  }).

  directive('internalClick', function() {
    return function(scope, elem, attrs) {
      elem.bind('click', function(event) {
        event.stopPropagation();
        scope.$apply(function() {
          scope.$eval(attrs.internalClick, {$event:event});
        });
      });
    };
  }).

  directive('clickMenu', ['$timeout', function ($timeout) {
    return {
      restrict: 'C',
      link: function(scope, elem, attrs) {
        var title, container, closeFn;

        title = elem.find('.title');
        container = elem.find('.container');

        title.click(function() {
          scope.$apply(function () {
            container.toggleClass('shown');
            elem.toggleClass('selected');

            if (!container.hasClass('shown')) {
              scope.$broadcast('menuClosed');
            }
            else {
              $timeout(function() {
                container.find(':input:first').focus();
              }, 0);
            }
          });
        });

        // Don't close the list on click if the attr 'no-auto-close' is present
        if (attrs.noAutoClose === undefined) {
          container.on('click', 'a', function(e) {
            scope.$apply(function () {
              closeFn();
            });
          });
        }

        closeFn = function() {
          container.removeClass('shown');
          elem.removeClass('selected');
          scope.$broadcast('menuClosed');
        }

        scope.$on('hideMenus', function(e, srcElem) {
          if (container.hasClass('shown') && srcElem[0] !== elem[0]) {
            closeFn();
          }
        });
      }
    };
  }]).

  run(['$rootScope', function ($rootScope) {
    $(document).on('click', function (e) {
      $rootScope.$apply(function () {
        $rootScope.$broadcast('hideMenus', $(e.target).closest('.click-menu'));
      });
    });
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
  }]).

  directive('onType', ['$timeout', function ($timeout) {
    return function (scope, elem, attrs) {
      var typingTimer, doneTypingInterval, doneTypingFn;

      doneTypingInterval = attrs.typingInterval || 300;

      doneTypingFn = function () {
        scope.$apply(attrs.onType);
      };

      elem.on('keyup change input', function () {
        $timeout.cancel(typingTimer);
        typingTimer = $timeout(doneTypingFn, doneTypingInterval);
      });
    };
  }]).

  directive('watchHeight', ['$parse', '$timeout', function ($parse, $timeout) {
    return function(scope, elem, attrs) {
      var expanded = $parse(attrs.expanded);

      scope.$watch(function () {
        return (expanded(scope) && elem.prop('scrollHeight'));
      }, function (newVal) {
        if (newVal) {
          elem.css('max-height', newVal);
        } else {
          elem.css('max-height', '')
        }
      });
    };
  }]).

  // directive('scrollWithMouse', [function () {
  //   return function(scope, elem, attrs) {
  //     var targetPos = 0;
  //     var timer;

  //     var scrollFn = function () {
  //       var scrollDiff = targetPos - elem.scrollLeft();
  //       if (Math.abs(scrollDiff) > 10) {
  //         var scrollAmount = (scrollDiff ^ 2) / 30;
  //         var maxAmount = 10;

  //         if (scrollAmount > maxAmount) {
  //           scrollAmount = maxAmount
  //         } else if (scrollAmount < (-1 * maxAmount)) {
  //           scrollAmount = -1 * maxAmount
  //         }
  //         elem.scrollLeft(elem.scrollLeft() + scrollAmount)
  //       }
  //     }

  //     elem.on('mousemove', function(e) {
  //       var elemWidth = elem.outerWidth();
  //       var scrollWidth = elem.prop('scrollWidth');

  //       if (scrollWidth > elemWidth) {
  //         var hiddenWidth = scrollWidth - elemWidth;
  //         var mousePos = e.pageX - elem.offset().left;

  //         targetPos = hiddenWidth * (mousePos/elemWidth);
  //       }
  //     });

  //     elem.on('mouseenter', function () {
  //       timer = setInterval(scrollFn, 15);
  //       elem.stop();
  //     });

  //     elem.on('mouseleave', function () {
  //       if (timer) {
  //         clearInterval(timer);
  //       }
  //       if (elem.scrollLeft() < 150) {
  //         elem.animate({scrollLeft: 0}, 1000);
  //       }
  //     });
  //   };
  // }]);

  directive('scrollArrows', [function () {
    return function(scope, elem, attrs) {

      elem.wrapInner('<div class="scroll"></div>');
      var scrollContainer = elem.find('.scroll');

      var scrollLeft = angular.element('<div class="scroll-left"></div>').appendTo(elem);
      var scrollRight = angular.element('<div class="scroll-right"></div>').appendTo(elem);

      var direction = 1;
      var timer;
      var interval = 15;
      var scrollAmount = 8;

      function scrollFn() {
        scrollContainer.scrollLeft(scrollContainer.scrollLeft() + direction * scrollAmount);
      }

      function startScroll(_direction_) {
        stopScroll();
        direction = _direction_;
        timer = setInterval(scrollFn, interval);
      }

      function stopScroll(direction) {
        if (timer) {
          clearInterval(timer);
        }
      }

      scrollLeft.on('mouseenter', function () {
        startScroll(-1);
      });
      scrollLeft.on('mouseleave', stopScroll);

      scrollRight.on('mouseenter', function () {
        startScroll(1);
      });
      scrollRight.on('mouseleave', stopScroll);
    };
  }]);