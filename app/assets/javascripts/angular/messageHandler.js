'use strict';

angular.module('journals.messageHandler', []).

  /*
   * The message handler sets a message object for an associated scope that is passed to it
   * This object has a message property, and a type which can be set to:
   *   - notification
   *   - error
   *   - process
   */

  factory('messageHandler', function () {
    var scope = {}, messageHandler = {};

    messageHandler.showProcess = function (text) {
      scope.message = { type: 'process', text: text };
    };

    messageHandler.showNotification = function (text) {
      scope.message = { type: 'notification', text: text };
    };

    messageHandler.showError = function (text) {
      scope.message = { type: 'error', text: text };
    };

    messageHandler.hide = function() {
      scope.message = null;
    };

    messageHandler.notifyOnRouteChange = function (text) {
      var clearBind = scope.$on('$routeChangeSuccess', function () {
        clearBind();
        messageHandler.showNotification(text);
      });
    };

    messageHandler.registerScope = function (recievedScope) {
      scope = recievedScope;
    };

    return messageHandler;
  }).

  controller('messageCtrl', ['$scope', 'messageHandler', '$timeout', function ($scope, messageHandler, $timeout) {
    messageHandler.registerScope($scope);
    $scope.show = false;

    var clearMessage;

    $scope.$watch('message', function (message) {
      if (message) {
        $scope.show = true;
        $timeout.cancel(clearMessage);
        if (message.type !== 'process') {
          clearMessage = $timeout(function () {
            $scope.message = null;
          }, 5000);
        }
      } else {
        $scope.show = false;
      }
    });
  }]);