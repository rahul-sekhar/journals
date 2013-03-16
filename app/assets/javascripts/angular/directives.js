'use strict';

angular.module('journals.directives', []).

  directive('filteredList', function () {
    return {
      restrict: 'E',
      scope: {
        list: '=',
        onSelect: '&',
        showProperty: '@'
      },
      template:
        '<div class="filtered-list" ng-show="list.length">' +
          '<div class="list" ng-show="listShown">' +
            '<input ng-model="filter" />' +
            '<ul>' +
              '<li ng-repeat="item in list | filter:filter">' +
                '<a href="" ng-click="select(item)">{{item[showProperty]}}</a>' +
              '</li>' +
            '</ul>' +
          '</div>' +
          '<a class="add" href="" ng-click="toggleList()">{{buttonText}}</a>' +
        '</div>',
      controller: function ($scope) {
        $scope.toggleList = function () {
          $scope.listShown = !$scope.listShown;
        };

        $scope.$on('menuClosed', function() {
          $scope.listShown = false;
        });

        $scope.$watch('listShown', function (value) {
          $scope.buttonText = value ? "Cancel" : "Add";
        });

        $scope.select = function (item) {
          $scope.listShown = false;
          $scope.filter = '';
          $scope.onSelect({value: item});
        };
      }
    };
  }).

  directive('clickMenu', function () {
    return function(scope, elem, attrs) {
      var title, container, closeFn;

      elem.addClass('click-menu');

      title = elem.find('.title');
      container = elem.find('.container');

      title.click(function() {
        scope.$apply(function () {
          container.toggleClass('shown');
          title.toggleClass('selected');

          if (!container.hasClass('shown')) {
            scope.$broadcast('menuClosed');
          }
        });
      });

      container.on('click', 'a', function() {
        scope.$apply(function () {
          closeFn();
        });
      });

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
    };
  }).

  run(['$rootScope', function ($rootScope) {
    $(document).on('click', function (e) {
      $rootScope.$apply(function () {
        $rootScope.$broadcast('hideMenus', $(e.target).closest('.click-menu'));
      });
    });
  }]);