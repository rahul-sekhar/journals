'use strict';

angular.module('journals.ajax', ['journals.messageHandler']).
  
  factory('ajax', ['$http', 'messageHandler', '$q', function($http, messageHandler, $q) {
    return function(params) {
      return $http(params).then(null, function(response) {
        messageHandler.showError(response);
        return $q.reject(response);
      });
    };
  }]);