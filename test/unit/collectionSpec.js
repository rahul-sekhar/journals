'use strict';

describe('Collection module', function() {
  beforeEach(module('journals.collection'));

  describe('collection', function() {
    var collection, model, httpBackend, timeout, rootScope;

    beforeEach(inject(function(_model_, $httpBackend, $timeout, $rootScope) {
      httpBackend = $httpBackend;
      timeout = $timeout;
      rootScope = $rootScope;
      model = _model_('object', '/objects');
      spyOn(model, 'create').andCallFake(function(data) {
        return angular.extend({ model: true }, data);
      });
    }));

    describe('with defaults', function() {
      beforeEach(inject(function(_collection_) {
        collection = _collection_(model);
        spyOn(collection, 'update').andCallThrough();
      }));

      describe('all()', function() {
        var result;

        describe('on success', function() {
          beforeEach(function() {
            httpBackend.expectGET('/objects').respond([{id: 1, name: "One"}, {id: 2, name: "Two"}]);
            result = collection.all();
          });

          it('sends a request to the server', function() {
            httpBackend.verifyNoOutstandingExpectation();
          });

          it('sets the result to an empty array', function() {
            expect(result).toEqual([]);
          });

          describe('on response', function() {
            beforeEach(function() {
              httpBackend.flush();
            });

            it('calls the update function for each object recieved', function() {
              expect(collection.update.callCount).toEqual(2);
              expect(collection.update.argsForCall[0][0]).toEqual({id: 1, name: "One"});
              expect(collection.update.argsForCall[1][0]).toEqual({id: 2, name: "Two"});
            });

            it('sets the result to the created instances', function() {
              expect(result).toEqual([{id: 1, name: "One", model: true}, {id: 2, name: "Two", model: true}]);
            });

            it('does not contact the server on subsequent calls', function() {
              var newResult = collection.all();
              httpBackend.verifyNoOutstandingRequest();
              expect(newResult).toBe(result);
            });

            it('does not set a timeout', function() {
              timeout.verifyNoPendingTasks();
            })
          });
        });
        
        describe('on failure', function() {
          beforeEach(function() {
            httpBackend.expectGET('/objects').respond(400);
            result = collection.all();
          });

          describe('on response', function() {
            beforeEach(function() {
              httpBackend.flush();
            });
            
            it('leaves the result unchanged', function() {
              expect(result).toEqual([]);
            });

            it('does not contact the server on immediate subsequent calls', function() {
              var newResult = collection.all();
              httpBackend.verifyNoOutstandingRequest();
              expect(newResult).toBe(result);
            });

            it('contacts the server once the timeout is finished if called again', function() {
              timeout.flush();
              httpBackend.verifyNoOutstandingRequest();
              httpBackend.expectGET('/objects').respond([{id: 1, name: "One"}]);
              var newResult = collection.all();
              httpBackend.verifyNoOutstandingExpectation();
              httpBackend.flush();
              expect(newResult).toEqual([{id: 1, name: "One", model: true}]);
              timeout.verifyNoPendingTasks();
            });
          });
        });
      });

      describe('get(id)', function() {
        var promise, success, error;

        beforeEach(function() {
          success = jasmine.createSpy();
          error = jasmine.createSpy();
        });

        describe('without the collection loaded', function() {
          describe('on success', function() {
            describe('when the object is found', function() {
              beforeEach(function() {
                httpBackend.expectGET('/objects').respond([{id: 1, name: "One"}, {id: 2, name: "Two"}]);
                promise = collection.get(2);
                promise.then(success, error);
              });

              it('contacts the server', function() {
                httpBackend.verifyNoOutstandingExpectation();
              });

              it('returns an unresolved promise', function() {
                expect(success).not.toHaveBeenCalled();
                expect(error).not.toHaveBeenCalled();
              });

              it('resolves the promise on server response', function() {
                httpBackend.flush();
                expect(error).not.toHaveBeenCalled();
                expect(success).toHaveBeenCalledWith({id: 2, name: "Two", model: true});
              });
            });

            describe('when the object is not found', function() {
              beforeEach(function() {
                httpBackend.expectGET('/objects').respond([{id: 1, name: "One"}, {id: 2, name: "Two"}]);
                promise = collection.get(3);
                promise.then(success, error);
              });
              
              it('rejects the promise on server response', function() {
                httpBackend.flush();
                expect(success).not.toHaveBeenCalled();
                expect(error).toHaveBeenCalled();
              });
            });
          });
          
          describe('on failure', function() {
            beforeEach(function() {
              httpBackend.expectGET('/objects').respond(400);
              promise = collection.get(2);
              promise.then(success, error);
            });

            it('rejects the promise on server response', function() {
              httpBackend.flush();
              expect(success).not.toHaveBeenCalled();
              expect(error).toHaveBeenCalled();
            });
          });
        });

        describe('with both all and get called', function() {
          beforeEach(function() {
            httpBackend.expectGET('/objects').respond([]);
            collection.all();
            collection.get(2);
          });

          it('contacts the server only once', function() {
            httpBackend.verifyNoOutstandingExpectation();
          });
        });

        describe('with the collection loaded', function() {
          beforeEach(function() {
            httpBackend.expectGET('/objects').respond([{id: 1, name: "One"}, {id: 2, name: "Two"}]);
            collection.all();
            httpBackend.flush();
            promise = collection.get(2);
          });

          it('does not contact the server again', function() {
            httpBackend.verifyNoOutstandingRequest();
          });

          it('returns a promise that has been resolved with the required instance', function() {
            promise.then(success, error);
            rootScope.$apply();
            expect(success).toHaveBeenCalledWith({id: 2, name: "Two", model: true});
          });
        });
      });

      describe('add()', function() {
        var instances, result;
        beforeEach(function() {
          httpBackend.expectGET('/objects').respond([{id: 1, name: "One"}, {id: 2, name: "Two"}]);
          instances = collection.all();
          httpBackend.flush();
          result = collection.add();
        });

        it('adds an empty instance to the beginning of the collection', function() {
          expect(instances).toEqualData([{model: true}, {id: 1, name: "One", model: true}, {id: 2, name: "Two", model: true}]);
        });

        it('returns the added instance', function() {
          expect(result).toBe(instances[0]);
        });
      });

      describe('update()', function() {
        var instances, result;

        beforeEach(function() {
          httpBackend.expectGET('/objects').respond([{id: 1, name: "One"}, {id: 2, name: "Two"}]);
          instances = collection.all();
          httpBackend.flush();
          model.create.reset();
        });

        describe('when the passed object has no ID', function() {
          it('throws an error', function() {
            expect(function() {
              collection.update({name: 'asdf'});
            }).toThrow('Object has no ID');
          });
        });

        describe('when the collection contains the passed object', function() {
          var targetInstance;

          beforeEach(function() {
            targetInstance = instances[1];
            targetInstance.load = jasmine.createSpy();
            result = collection.update({id: 2, name: "New name"})
          });

          it('loads the matching instance with the passed data', function() {
            expect(targetInstance.load).toHaveBeenCalledWith({id: 2, name: "New name"});
          });

          it('returns the matching instance', function() {
            expect(result).toBe(targetInstance);
          });
        });

        describe('when the collection does not contain the passed object', function() {
          beforeEach(function() {
            result = collection.update({id: 3, name: "Some name"})
          });

          it('creates an instance with the passed data', function() {
            expect(model.create).toHaveBeenCalledWith({id: 3, name: "Some name"});
          });

          it('adds the created instance to the collection object', function() {
            expect(instances).toEqualData([
              {id: 1, name: "One", model: true}, 
              {id: 2, name: "Two", model: true}, 
              {id: 3, name: "Some name", model: true}
            ]);
          });

          it('returns the matching instance', function() {
            expect(result).toBe(instances[2]);
          });
        });
      });
    });

    /*----- Custom options -----*/
    describe('with a custom url', function() {
      beforeEach(inject(function(_collection_) {
        collection = _collection_(model, {
          url: '/custom/path'
        });
      }));

      describe('all()', function() {
        it('sends a request to the custom path', function() {
          httpBackend.expectGET('/custom/path').respond([]);
          collection.all();
          httpBackend.verifyNoOutstandingExpectation();
        });
      });
    });
  });
});