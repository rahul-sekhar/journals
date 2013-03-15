'use strict';

angular.module('journals.user', ['journals.ajax']).
  factory('User', ['ajax', '$timeout', function (ajax, $timeout) {
    var promise, User = {}, loadFn;

    loadFn = function () {
      promise = ajax({ url: '/user' }).
        then(function (response) {
          angular.copy(response.data, User);
        }, function () {
          // Set a timeout for the next try
          $timeout(function () {
            loadFn();
          }, 30000);
        });
    };

    loadFn();

    return User;
  }]);