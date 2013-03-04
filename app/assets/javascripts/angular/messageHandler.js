'use strict';

angular.module('journals.messageHandler', []).

  factory('messageHandler', function() {
    var messageHandler = {};

    messageHandler.showError = function(error) {
      console.log(error, error.data);
    };

    return messageHandler;
  });