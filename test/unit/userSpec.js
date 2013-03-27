'use strict';

describe('User module', function() {
  beforeEach(module('journals.user'));

  describe('User', function () {
    var User, httpBackend, injector, success, error;

    beforeEach(inject(function($injector, $httpBackend) {
      httpBackend = $httpBackend;
      injector = $injector;
      success = jasmine.createSpy();
      error = jasmine.createSpy();
    }));

    describe('for a valid server response', function() {
      beforeEach(function () {
        httpBackend.expectGET('/user.json').respond({type: 'Student', other: 'something'});
        User = injector.get('User');
        User.promise.then(success, error);
      });

      it('sends a message to the server', function() {
        httpBackend.verifyNoOutstandingExpectation();
      });

      it('initializes an empty user object with a promise', function() {
        expect(User).toEqualData({ promise: {} });
      });

      it('does not resolve the promise', function () {
        expect(success).not.toHaveBeenCalled();
        expect(error).not.toHaveBeenCalled();
      });

      describe('on response', function () {
        beforeEach(function () {
          httpBackend.flush();
        });

        it('resolves the promise', function () {
          expect(success).toHaveBeenCalled();
          expect(error).not.toHaveBeenCalled();
        });

        it('loads server response data into the User object', function() {
          expect(User).toEqualData({type: 'Student', other: 'something', promise: {}});
        });

        it('promise returns a resolved promise', inject(function ($rootScope) {
          success.reset();
          User.promise.then(success, error);
          $rootScope.$apply();
          expect(success).toHaveBeenCalled();
          expect(error).not.toHaveBeenCalled();
        }));
      });
    });

    describe('for an invalid server response', function() {
      beforeEach(function() {
        httpBackend.expectGET('/user.json').respond(404);
        User = injector.get('User');
        User.promise.then(success, error);
        httpBackend.flush();
      });

      it('leaves the User object empty', function() {
        expect(User).toEqualData({ promise: {} });
      });

      it('rejects the promise', function () {
        expect(success).not.toHaveBeenCalled();
        expect(error).toHaveBeenCalled();
      });
    });
  });
});