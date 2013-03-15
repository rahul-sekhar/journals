'use strict';

angular.module('journals.groups', ['journals.collection', 'journals.model']).

  factory('Groups', ['collection', 'model', 'editableFieldsExtension',
    function (collection, model, editableFieldsExtension) {
      var groupModel = model('group', '/groups', {
        extensions: [editableFieldsExtension('name')]
      });

      return collection(groupModel);
    }]).

  controller('GroupsCtrl', ['$scope', 'Groups', function ($scope, Groups) {
    $scope.groups = Groups.all();

    $scope.add = function () {
      Groups.add();
    };
  }]);