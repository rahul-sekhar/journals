'use strict';

angular.module('journals.user', ['journals.messageHandler']).
  factory('User', ['$http', 'messageHandler', '$timeout', function ($http, messageHandler, $timeout) {
    var promise, User = {}, loadFn;

    loadFn = function () {
      promise = $http.get('/user').
        then(function (response) {
          angular.copy(response.data, User);
        }, function (response) {
          messageHandler.showError(response);

          // Set a timeout for the next try
          $timeout(function () {
            loadFn();
          }, 30000);

        });
    };

    loadFn();

    return User;
  }]);