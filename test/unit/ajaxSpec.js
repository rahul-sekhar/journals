'use strict';

describe('ajax module', function () {
  beforeEach(module('journals.ajax'));

  describe('ajax', function () {
    var ajax, messageHandler, httpBackend, promise, success, error;

    beforeEach(inject(function (_ajax_, _messageHandler_, $httpBackend) {
      ajax = _ajax_;
      messageHandler = _messageHandler_;
      httpBackend = $httpBackend;
      spyOn(messageHandler, 'showProcess');
      spyOn(messageHandler, 'showNotification');
      spyOn(messageHandler, 'showError');

      success = jasmine.createSpy();
      error = jasmine.createSpy();
    }));

    it('adds the json extension with query parameters', function () {
      httpBackend.expectGET('/path.json?a=1&b=2').respond(200);
      ajax({ url: '/path?a=1&b=2' });
      httpBackend.verifyNoOutstandingExpectation();
    });

    describe('on success', function () {
      beforeEach(function () {
        httpBackend.expectPOST('/path.json', { data: 'val' }).respond(200, 'Some text');
        promise = ajax({ url: '/path', method: 'POST', data: { data: 'val' } });
        promise.then(success, error);
      });

      it('sends a message to the server', function () {
        httpBackend.verifyNoOutstandingExpectation();
      });

      it('displays a process message', function () {
        expect(messageHandler.showProcess).toHaveBeenCalled();
        expect(messageHandler.showNotification).not.toHaveBeenCalled();
        expect(messageHandler.showError).not.toHaveBeenCalled();
      });

      it('does not immediately resolve the returned promise', function () {
        expect(success).not.toHaveBeenCalled();
        expect(error).not.toHaveBeenCalled();
      });

      describe('on response', function () {
        beforeEach(function () {
          httpBackend.flush();
        });

        it('shows a notification', function () {
          expect(messageHandler.showNotification).toHaveBeenCalled();
          expect(messageHandler.showError).not.toHaveBeenCalled();
        });

        it('resolves the promise with recieved data', function () {
          expect(success).toHaveBeenCalled();
          expect(error).not.toHaveBeenCalled();
          expect(success.mostRecentCall.args[0].data).toEqual('Some text');
        });
      });
    });

    describe('on failure', function () {
      beforeEach(function () {
        httpBackend.expectPOST('/path.json', { data: 'val' }).respond(400);
        promise = ajax({ url: '/path', method: 'POST', data: { data: 'val' }, error: 'Some error' });
        promise.then(success, error);
        httpBackend.flush();
      });

      it('shows a error with the passed message', function () {
        expect(messageHandler.showNotification).not.toHaveBeenCalled();
        expect(messageHandler.showError).toHaveBeenCalledWith('Some error');
      });

      it('rejects the promise', function () {
        expect(success).not.toHaveBeenCalled();
        expect(error).toHaveBeenCalled();
      });
    });

    describe('on failure with a status of 0', function () {
      beforeEach(function () {
        httpBackend.expectPOST('/path.json', { data: 'val' }).respond(0);
        ajax({ url: '/path', method: 'POST', data: { data: 'val' }, error: 'Some error' });
        httpBackend.flush();
      });

      it('shows a error with a fixed message', function () {
        expect(messageHandler.showError).toHaveBeenCalledWith('The server could not be reached. Please check your connection.');
      });
    });

    describe('on failure with a status of 422', function () {
      beforeEach(function () {
        httpBackend.expectPOST('/path.json', { data: 'val' }).respond(422, 'Some message');
        ajax({ url: '/path', method: 'POST', data: { data: 'val' }, error: 'Some error' });
        httpBackend.flush();
      });

      it('shows a error with the response message', function () {
        expect(messageHandler.showError).toHaveBeenCalledWith('Some message');
      });
    });
  });
});