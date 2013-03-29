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
              '<li ng-repeat="item in list | filter: filterObj">' +
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
            title.toggleClass('selected');

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
          title.removeClass('selected');
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

  directive('tinymce', [function () {
    return {
      require: 'ngModel',
      link: function(scope, elem, attrs, ngModel) {
        var saveFn;
        elem.tinymce({
          script_url: '/tinymce/tiny_mce.js',
          width: 474,
          theme : "advanced",
          plugins : "autolink,lists,inlinepopups,paste",
          content_css: "/assets/tinymce/main.css",
          theme_advanced_buttons1 : "bold,italic,strikethrough,|,link,unlink,|,bullist,numlist,|,image",
          theme_advanced_toolbar_location : "top",
          theme_advanced_toolbar_align : "center",
          theme_advanced_resizing : true,
          theme_advanced_resize_horizontal : false,
          theme_advanced_statusbar_location : "bottom",
          theme_advanced_path: false,
          relative_urls: false,
          formats: {
            strikethrough : { inline : 'span', 'classes' : 'strikethrough', exact : true }
          },
          onchange_callback: function(e) {
            if (this.isDirty()) {
              saveFn();
              return true;
            }
          },
          oninit: function() {
            elem.trigger('editorInit');
          }
        });

        saveFn = function() {
          elem.tinymce().save();
          ngModel.$setViewValue(elem.val());
        };

        scope.$on('saveText', function () {
          saveFn();
        });
      }
    };
  }]).

  directive('observationEditor', [function () {
    return function(scope, elem, attrs) {
      var checkHeightFn, obsIframe, buttonList;

      // get elements on editor initialization
      elem.on('editorInit', function () {
        obsIframe = elem.parent().find('#' + elem.attr('id') + '_ifr');
        buttonList = elem.parent().find('#observation-buttons');
        checkHeightFn();
      });

      // Change the height to equal the button list height
      checkHeightFn = function () {
        if (obsIframe && ( buttonList.outerHeight() + 10) > obsIframe.outerHeight()) {
          obsIframe[0].style.height = buttonList.outerHeight() + 10 + 'px';
        }
      }

      // check height on a check height event
      scope.$on('checkHeight', checkHeightFn);
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
  }]);