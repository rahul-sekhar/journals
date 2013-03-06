'use strict';

angular.module('journals.filteredList', []).
  
  directive('filteredList', function() {
    return {
      restrict: 'E',
      scope: {
        list: '=',
        onSelect: '&',
        showProperty: '@'
      },
      template:
        '<div class="filtered-list" ng-show="list.length">' +
          '<a class="add" href="" ng-click="toggleList()">{{buttonText}}</a>' +
          '<div class="list" ng-show="listShown">' +
            '<input ng-model="filter" />' +
            '<ul>' +
              '<li ng-repeat="item in list | filter:filter">' +
                '<a href="" ng-click="select(item)">{{item[showProperty]}}</a>' +
              '</li>' +
            '</ul>' +
          '</div>' +
        '</div>',
      controller: function($scope) {
        $scope.toggleList = function() {
          $scope.listShown = !$scope.listShown;
        };

        $scope.$watch('listShown', function(value) {
          $scope.buttonText = value ? "Cancel" : "Add";
        });

        $scope.select = function(item) {
          $scope.listShown = false;
          $scope.onSelect({value:item});
        };
      }
    };
  });