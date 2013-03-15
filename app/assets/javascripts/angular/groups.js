'use strict';

angular.module('journals.groups', ['journals.collection', 'journals.model']).

  factory('Groups', ['collection', 'model',
    function (collection, model) {
      var groupModel = model('group', '/groups');

      return collection(groupModel);
    }]).

  controller('GroupsCtrl', ['$scope', 'Groups', function ($scope, Groups) {
    $scope.groups = Groups.all();

    $scope.add = function () {
      Groups.add({_edit: 'name'});
    };
  }]);