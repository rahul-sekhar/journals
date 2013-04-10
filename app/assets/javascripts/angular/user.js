'use strict';

angular.module('journals.user', ['journals.ajax']).
  factory('User', ['ajax', '$timeout', '$q', function (ajax, $timeout, $q) {
    var promise, User = {}, loadFn;

    User.promise = ajax({ url: '/user' }).
      then(function (response) {
        angular.copy(response.data, User);
        User.promise = $q.when();
      });

    return User;
  }]);