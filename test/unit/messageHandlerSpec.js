'use strict';

describe('messageHandler module', function() {
  beforeEach(module('journals.messageHandler'));

  describe('messageHandler', function() {
    var scope, messageHandler, rootScope;

    beforeEach(inject(function(_messageHandler_, $rootScope) {
      rootScope = $rootScope;
      scope = $rootScope.$new();
      messageHandler = _messageHandler_;
      messageHandler.registerScope(scope);
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

    describe('showError(text)', function() {
      beforeEach(function() {
        messageHandler.showError('Some text');
      });

      it('sets the scope message', function() {
        expect(scope.message).toEqual({type: 'error', text: 'Some text'});
      });
    });

    describe('hide()', function() {
      beforeEach(function() {
        messageHandler.hide();
      });

      it('sets the scope message to null', function() {
        expect(scope.message).toBeNull();
      });
    });

    describe('notifyOnRouteChange(text', function() {
      beforeEach(function() {
        messageHandler.notifyOnRouteChange('Some text');
      });

      it('does not immediately set the scope message', function() {
        expect(scope.message).toBeUndefined();
      });

      describe('after a route change', function() {
        beforeEach(function() {
          rootScope.$broadcast('$routeChangeSuccess');
        });

        it('sets the scope message', function() {
          expect(scope.message).toEqual({type: 'notification', text: 'Some text'});
        });

        it('does not set the scope message after a second route change', function() {
          scope.message = {};
          rootScope.$broadcast('$routeChangeSuccess');
          expect(scope.message).toEqual({});
        });
      });
    });
  });


  describe('messageCtrl', function() {
    var scope, messageHandler;

    beforeEach(inject(function($rootScope, $controller, _messageHandler_) {
      messageHandler = _messageHandler_;
      spyOn(messageHandler, 'registerScope');
      scope = $rootScope.$new();
      $controller('messageCtrl', {$scope: scope});
    }));

    it('sets the scope of the messageHandler', function() {
      expect(messageHandler.registerScope).toHaveBeenCalledWith(scope);
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