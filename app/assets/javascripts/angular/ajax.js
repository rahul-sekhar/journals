'use strict';

angular.module('journals.ajax', ['journals.messageHandler']).

  factory('ajax', ['$http', 'messageHandler', '$q', function ($http, messageHandler, $q) {
    return function (options) {
      var defaults = {
        method: 'GET',
        data: null,
        process: 'Working...',
        notification: 'Done.',
        error: 'An error occured. Please contact us if this problem persists.'
      };
      options = angular.extend(defaults, options);

      messageHandler.showProcess(options.process);
      return $http({ url: options.url, method: options.method, data: options.data }).

        then(function (response) {
          messageHandler.showNotification(options.notification);
          return response;
        },
          function (response) {
            var message;

            if (response.status === 0) {
              message = 'The server could not be reached. Please check your connection.';
            } else if (response.status === 422) {
              message = response.data;
            } else {
              message = options.error;
            }

            messageHandler.showError(message);
            return $q.reject(response);
          });
    };
  }]);