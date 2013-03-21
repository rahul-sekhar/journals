'use strict';

angular.module('journals.changePassword', ['journals.ajax']).

  controller('ChangePasswordCtrl', ['$scope', 'ajax', function ($scope, ajax) {
    $scope.$watch('dialogs.changePassword', function (value) {
      $scope.user = {};
    });

    $scope.submit = function () {
      ajax({url: '/change_password', method: 'PUT', data: { user: $scope.user }}).
        then(function () {
          $scope.dialogs.changePassword = false;
        });
    };
  }]);