'use strict';

angular.module('journals.user', ['journals.messageHandler']).
  
  factory('User', ['$http', 'messageHandler', '$timeout', function($http, messageHandler, $timeout) {
    var User = {};

    var promise;
    var load = function() {
      promise = $http.get('/user').
        then(function(response) {
          angular.copy(response.data, User);
        }, function(response) {
          messageHandler.showError(response);

          // Set a timeout for the next try
          $timeout(function() {
            load();
          }, 30000)
          
        });
    };

    load();

    return User
  }]);