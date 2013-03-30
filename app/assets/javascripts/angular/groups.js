'use strict';

angular.module('journals.groups', ['journals.collection', 'journals.model', 'journals.confirm']).

  factory('Groups', ['collection', 'model',
    function (collection, model) {
      var groupModel = model('group', '/groups');

      return collection(groupModel);
    }]).

  controller('GroupsCtrl', ['$scope', 'Groups', 'confirm', function ($scope, Groups, confirm) {
    $scope.groups = Groups.all();

    $scope.add = function () {
      Groups.add({_edit: 'name'});
    };

    $scope.delete = function (group) {
      if (confirm('Are you sure you want to delete the group "' + group.name + '"?')) {
        group.delete();
      }
    };
  }]);