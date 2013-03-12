describe('cachedCollection module', function() {
  beforeEach(module('journals.cachedCollection'));

  describe('cachedCollection', function() {
    var cachedCollection, httpBackend, callback, messageHandler;
    
    beforeEach(inject(function($httpBackend, _cachedCollection_, _messageHandler_) {
      httpBackend = $httpBackend;
      messageHandler = _messageHandler_;
      spyOn(messageHandler, 'showError');
      callback = jasmine.createSpy().andCallFake(angular.identity);
      cachedCollection = _cachedCollection_('/path', 'thing', callback);
    }));

    describe('on a call to the all function', function() {
      it('loads objects', function() {
        httpBackend.expectGET('/path').respond([]);
        cachedCollection.all();
        httpBackend.verifyNoOutstandingExpectation();
      });

      it('does not reload objects if the objects have already been loaded', function() {
        httpBackend.expectGET('/path').respond([]);
        cachedCollection.all();
        httpBackend.flush();
        cachedCollection.all();
        httpBackend.verifyNoOutstandingExpectation();
      });

      it('reloads objects if the objects have failed to load after a timeout', inject(function($timeout) {
        httpBackend.expectGET('/path').respond(404);
        cachedCollection.all();
        httpBackend.flush();
        cachedCollection.all();
        httpBackend.verifyNoOutstandingExpectation();

        httpBackend.expectGET('/path').respond([]);
        $timeout.flush();
        cachedCollection.all();
        httpBackend.verifyNoOutstandingExpectation();
      }));

      describe('with a valid server response', function() {
        var objects;

        beforeEach(function() {
          httpBackend.expectGET('/path').respond([{id: 2, name: 'Two'}, {id: 10, name: 'Ten'}]);
          objects = cachedCollection.all();
        });

        it('updates references to the function with the loaded data', function() {
          expect(objects).toEqual([]);
          httpBackend.flush();
          expect(objects).toEqualData([{id: 2, name: 'Two'}, {id: 10, name: 'Ten'}]);
        });

        it('transforms each returned object', function() {
          callback.andCallFake(function(arg) {
            arg.transformed = true;
            return arg;
          });
          httpBackend.flush();
          expect(objects).toEqualData([{id: 2, name: 'Two', transformed: true}, {id: 10, name: 'Ten', transformed: true}]);
        });
      });

      describe('with an invalid server response', function() {
        var objects;

        beforeEach(inject(function($injector) {
          httpBackend.expectGET('/path').respond(404, 'Some error');
          objects = cachedCollection.all();
        }));

        it('sends an error to the messageHandler', function() {
          httpBackend.flush();
          expect(messageHandler.showError).toHaveBeenCalled();
        });

        it('updates references to the function to an empty array', function() {
          expect(objects).toEqual([]);
          httpBackend.flush();
          expect(objects).toEqual([]);
        });
      });
    });

    describe('get(id)', function() {
      it('loads objects', function() {
        httpBackend.expectGET('/path').respond([]);
        cachedCollection.get(5);
        httpBackend.verifyNoOutstandingExpectation();
      });

      it('does not reload objects if the objects have already been loaded', function() {
        httpBackend.expectGET('/path').respond([]);
        cachedCollection.all();
        httpBackend.flush();
        cachedCollection.get(3);
        httpBackend.verifyNoOutstandingExpectation();
      });

      it('reloads objects if the objects have failed to load', inject(function($timeout) {
        httpBackend.expectGET('/path').respond(404);
        cachedCollection.all();
        httpBackend.flush();
        cachedCollection.get(7);
        httpBackend.verifyNoOutstandingExpectation();

        httpBackend.expectGET('/path').respond([]);
        $timeout.flush();
        cachedCollection.get(7);
        httpBackend.verifyNoOutstandingExpectation();
      }));

      describe('the returned promise', function() {
        var success, error;

        beforeEach(function() {
          success = jasmine.createSpy('success'), error = jasmine.createSpy('error');
        });

        it('is resolved with the relevant object with a valid server response', function() {
          httpBackend.expectGET('/path').respond([{id: 1, name: "One"}, {id: 5, name: "Five"}, {id: 7, name: "Seven"}]);
          cachedCollection.get(5).then(success, error);
          expect(success).not.toHaveBeenCalled();
          httpBackend.flush();
          expect(success).toHaveBeenCalled();
          expect(success.mostRecentCall.args[0]).toEqualData({id: 5, name: "Five"});
        });

        it('returns a object that has been transformed with the callback function', function() {
          callback.andCallFake(function(arg) {
            arg.transformed = true;
            return arg;
          });

          httpBackend.expectGET('/path').respond([{id: 1, name: "One"}, {id: 5, name: "Five"}, {id: 7, name: "Seven"}]);
          cachedCollection.get(5).then(success, error);
          httpBackend.flush();
          expect(success.mostRecentCall.args[0]).toEqualData({id: 5, name: "Five", transformed: true});
        });

        it('is rejected if the object is not present', function() {
          httpBackend.expectGET('/path').respond([{id: 1, name: "One"}, {id: 6, name: "Six"}, {id: 7, name: "Seven"}]);
          cachedCollection.get(5).then(success, error);
          httpBackend.flush();
          expect(success).not.toHaveBeenCalled();
          expect(error).toHaveBeenCalled();
        });

        it('is rejected for an invalid server response', function() {
          httpBackend.expectGET('/path').respond(404, 'Some error');
          cachedCollection.get(5).then(success, error);
          httpBackend.flush();
          expect(success).not.toHaveBeenCalled();
          expect(error).toHaveBeenCalled();
        });
      });
    });
  });
});