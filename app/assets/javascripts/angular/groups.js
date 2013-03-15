'use strict';

angular.module('journals.groups', ['journals.collection', 'journals.model']).

  factory('Groups', ['collection', 'model',
    function (collection, model) {
      var groupModel = model('group', '/groups');

      return collection(groupModel);
    }]).

  controller('GroupsCtrl', ['$scope', 'Groups', '$timeout', function ($scope, Groups, $timeout) {
    $scope.groups = Groups.all();

    $scope.add = function () {
      var group = Groups.add();
      $timeout(function () {
        $scope.$broadcast('editField', group, 'name');
      }, 0);
    };
  }]);