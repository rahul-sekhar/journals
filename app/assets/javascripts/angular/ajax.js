'use strict';

angular.module('journals.ajax', ['journals.messageHandler']).

  factory('ajax', ['$http', 'messageHandler', '$q', function ($http, messageHandler, $q) {
    return function (options) {
      var defaults, urlParts;
      defaults = {
        method: 'GET',
        data: null,
        params: null,
        notification: 'Done',
        error: 'An error occurred - please contact a school administrator if the problem persists',
        addExtension: true
      };
      options = angular.extend(defaults, options);

      if (!options.process) {
        if (options.method.toLowerCase() === 'get') {
          options.process = 'Loading...'
        }
        else {
          options.process = 'Saving...'
        }
      };

      if (options.addExtension) {
        urlParts = options.url.split('?');
        urlParts[0] += '.json';
        options.url = urlParts.join('?');
      }

      messageHandler.showProcess(options.process);
      return $http({ url: options.url, method: options.method, data: options.data, params: options.params }).

        then(function (response) {
          if (options.method.toLowerCase() !== 'get') {
            messageHandler.showNotification(options.notification);
          } else {
            messageHandler.hide();
          }
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