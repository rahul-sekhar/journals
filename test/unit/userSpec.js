'use strict';

describe('User module', function() {
  beforeEach(module('journals.user'));

  describe('for a valid server response', function() {
    var User, httpBackend;

    beforeEach(inject(function($injector, $httpBackend) {
      httpBackend = $httpBackend;
      httpBackend.expectGET('/user.json').respond({type: 'Student', other: 'something'});
      User = $injector.get('User');
    }));

    it('sends a message to the server', function() {
      httpBackend.verifyNoOutstandingExpectation();
    });

    it('initializes an empty user object', function() {
      expect(User).toEqual({});
    });

    it('loads server response data into the User object', function() {
      httpBackend.flush();
      expect(User).toEqual({type: 'Student', other: 'something'});
    });
  });

  describe('for an invalid server response', function() {
    var User, httpBackend;

    beforeEach(inject(function($injector, $httpBackend) {
      httpBackend = $httpBackend;
      httpBackend.expectGET('/user.json').respond(404);
      User = $injector.get('User');
    }));

    it('sends a message to the server', function() {
      httpBackend.verifyNoOutstandingExpectation();
    });

    it('leaves the User object empty after response', function() {
      httpBackend.flush();
      expect(User).toEqual({});
    });

    it('reloads the user object after a timeout until a valid response is recieved', inject(function($timeout) {
      httpBackend.flush();
      httpBackend.expectGET('/user.json').respond(404, 'Some error');
      httpBackend.verifyNoOutstandingRequest();
      $timeout.flush();
      httpBackend.verifyNoOutstandingExpectation();

      httpBackend.flush();
      httpBackend.expectGET('/user.json').respond({type: 'Teacher'});
      httpBackend.verifyNoOutstandingRequest();
      $timeout.flush();
      httpBackend.verifyNoOutstandingExpectation();

      httpBackend.flush();
      $timeout.verifyNoPendingTasks();
      httpBackend.verifyNoOutstandingExpectation();
    }));
  });
});