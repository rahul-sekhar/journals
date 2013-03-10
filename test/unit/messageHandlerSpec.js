'use strict';

describe('messageHandler module', function() {
  beforeEach(module('journals.messageHandler'));

  describe('messageHandler', function() {
    var scope, messageHandler;

    beforeEach(inject(function(_messageHandler_) {
      scope = {};
      messageHandler = _messageHandler_;
      messageHandler.setScope(scope);
    }));
    
    describe('showProcess(text)', function() {
      beforeEach(function() {
        messageHandler.showProcess('Some text');
      });

      it('sets the scope message', function() {
        expect(scope.message).toEqual({type: 'process', text: 'Some text'});
      });
    });

    describe('showNotification(text)', function() {
      beforeEach(function() {
        messageHandler.showNotification('Some text');
      });

      it('sets the scope message', function() {
        expect(scope.message).toEqual({type: 'notification', text: 'Some text'});
      });
    });

    describe('showError(error, text)', function() {
      it('sets a message when the status is 0', function() {
        messageHandler.showError({status: 0, data: 'Error!'}, 'Some message');
        expect(scope.message).toEqual({type: 'error', text: 'The server could not be reached. Please check your connection.'});
      });

      it('sets the passed text for a null error object', function() {
        messageHandler.showError(null, 'Some message.');
        expect(scope.message).toEqual({type: 'error', text: 'Some message.'});
      });

      it('sets the error object text for a status of 422', function() {
        messageHandler.showError({status: 422, data: 'Error!'}, 'Some message');
        expect(scope.message).toEqual({type: 'error', text: 'Error!'});
      })

      it('sets the passed text with an added message for any other status', function() {
        messageHandler.showError({status: 402, data: 'Error!'}, 'Some message.');
        expect(scope.message).toEqual({type: 'error', text: 'Some message. Please contact us if the problem persists.'});
      });
    });
  });
  

  describe('messageCtrl', function() {
    var scope, messageHandler;

    beforeEach(inject(function($rootScope, $controller, _messageHandler_) {
      messageHandler = _messageHandler_;
      spyOn(messageHandler, 'setScope');
      scope = $rootScope.$new();
      $controller('messageCtrl', {$scope: scope});
    }));

    it('sets the scope of the messageHandler', function() {
      expect(messageHandler.setScope).toHaveBeenCalledWith(scope);
    });

    it('sets show to false', function() {
      expect(scope.show).toEqual(false);
    });

    describe('when an error message is set', function() {
      beforeEach(function() {
        scope.message = { type: 'error', text: 'Some error' };
        scope.$apply();
      });
      
      it('sets show to true', function() {
        expect(scope.show).toEqual(true);
      });

      it('sets show to false and clears the message after a timeout', inject(function($timeout) {
        $timeout.flush();
        expect(scope.show).toEqual(false);
        expect(scope.message).toBeNull();
      }));
    });

    describe('when a notification is set', function() {
      beforeEach(function() {
        scope.message = { type: 'notification', text: 'Some error' };
        scope.$apply();
      });
      
      it('sets show to true', function() {
        expect(scope.show).toEqual(true);
      });

      it('sets show to false and clears the message after a timeout', inject(function($timeout) {
        $timeout.flush();
        expect(scope.show).toEqual(false);
        expect(scope.message).toBeNull();
      }));
    });

    describe('when a process is set', function() {
      beforeEach(function() {
        scope.message = { type: 'process', text: 'Some error' };
        scope.$apply();
      });
      
      it('sets show to true', function() {
        expect(scope.show).toEqual(true);
      });

      it('does not set a timeout or clear the message', inject(function($timeout) {
        $timeout.verifyNoPendingTasks();
        expect(scope.message).toEqual({ type: 'process', text: 'Some error' });
      }));
    });
  });
});