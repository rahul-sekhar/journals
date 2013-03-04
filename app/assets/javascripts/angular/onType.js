'use strict';

angular.module('journals.onType', []).
  directive('onType', ['$timeout', function($timeout) {
    return function( scope, elem, attrs ) {
      var typingTimer;
      var doneTypingInterval = attrs.typingInterval || 300;
      
      var doneTyping = function() {
        scope.$apply(attrs.onType);
      }

      elem.on('keyup change input', function(){
        $timeout.cancel(typingTimer);
        typingTimer = $timeout(doneTyping, doneTypingInterval);
      });
    };
  }]);