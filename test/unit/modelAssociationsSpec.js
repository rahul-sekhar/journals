'use strict';

describe('Model associations module', function () {
  beforeEach(module('journals.model.associations'));

  /*---------------- Associations extension --------------------*/
  describe('association', function () {
    var extension, collection, model, deferred;

    beforeEach(function () {
      collection = {};

      module(function ($provide) {
        $provide.value('collection', collection);
      });
    });

    describe('with defaults', function () {
      beforeEach(inject(function (association, $q) {
        deferred = $q.defer();

        // get resolves promises with a string for each instance
        // it rejects the promise for an ID of 6
        collection.get = jasmine.createSpy().andCallFake(function (id) {
          return deferred.promise.
            then(function () {
              if (id == 6) {
                return $q.reject();
              }
              return 'instance ' + id;
            });
        });

        extension = association('collection', 'assoc');
      }));

      describe('with no association id field present', function () {
        beforeEach(function () {
          model = { id: 3, name: 'Something' };
          extension(model);
        });

        it('does not get any association models', function () {
          expect(collection.get).not.toHaveBeenCalled();
        });

        it('adds an empty association field to the model', function () {
          expect(model).toEqual({ id: 3, name: 'Something', assocs: [] });
        });
      });

      describe('with an association field', function () {
        beforeEach(function () {
          model = { id: 3, name: 'Something',  assoc_ids: [3, 6, 8] };
          extension(model);
        });

        it('gets a model for each association id', function () {
          expect(collection.get.callCount).toEqual(3);
          expect(collection.get.argsForCall[0][0]).toEqual(3);
          expect(collection.get.argsForCall[1][0]).toEqual(6);
          expect(collection.get.argsForCall[2][0]).toEqual(8);
        });

        it('adds an empty association field to the model', function () {
          expect(model.assocs).toEqual([]);
        });

        it('sets the association field to the returned instances for resolved promises', inject(function ($rootScope) {
          deferred.resolve();
          $rootScope.$apply();
          expect(model.assocs).toEqual(['instance 3', 'instance 8']);
        }));
      });

      describe('on setup', function () {
        var httpBackend;

        beforeEach(inject(function ($httpBackend) {
          httpBackend = $httpBackend;
          model = { url: function () { return '/objects/3' } };
          extension.setup(model);
        }));

        describe('remainingAssocs()', function () {
          var result, objects;

          beforeEach(function () {
            objects = [{id: 1}, {id: 5, deleted: false}, {id: 3}, {id: 6, deleted: true}, {id: 7}];
            collection.all = jasmine.createSpy().andReturn(objects);
            model.assocs = [objects[0], objects[2]];
            result = model.remainingAssocs();
          });

          it('calls collection.all()', function () {
            expect(collection.all).toHaveBeenCalled();
          });

          it('returns the remaining instances, ignoring deleted ones', function () {
            expect(result).toEqual([objects[1], objects[4]]);
          });

          it('returns the same array object on subsequent calls', function () {
            var newResult = model.remainingAssocs();
            expect(result).toBe(newResult);
          });
        });

        describe('newAssoc()', function () {
          var result;

          beforeEach(function () {
            collection.add = jasmine.createSpy().andReturn(5);
            model.assocs = [1,2];
            model.id = 7;
            result = model.newAssoc({data: 'val'});
          });

          it('calls collection.add(), passing the parent and any other data', function () {
            expect(collection.add).toHaveBeenCalledWith({ _parent: model, data: 'val' });
          });

          it('adds the new association', function () {
            expect(model.assocs).toEqual([5,1,2]);
          });

          it('returns the new association', function () {
            expect(result).toEqual(5);
          });
        });

        describe('addAssoc(instance, local)', function () {
          describe('on success', function () {
            beforeEach(function () {
              httpBackend.expectPOST('/objects/3/assocs/5.json').respond(200);
              model.assocs = [{id: 1, name: "One"}, {id: 2, name: "Two"}];
              model.addAssoc({id: 5, name: "Five"});
            });

            it('sends a message to the server', function () {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('adds the new instance', function () {
              expect(model.assocs).toEqual([{id: 1, name: "One"}, {id: 2, name: "Two"}, {id: 5, name: "Five"}]);
              httpBackend.flush();
              expect(model.assocs).toEqual([{id: 1, name: "One"}, {id: 2, name: "Two"}, {id: 5, name: "Five"}]);
            });
          });

          describe('on failure', function () {
            beforeEach(function () {
              httpBackend.expectPOST('/objects/3/assocs/5.json').respond(400);
              model.assocs = [{id: 1, name: "One"}, {id: 2, name: "Two"}];
              model.addAssoc({id: 5, name: "Five"});
              httpBackend.flush();
            });

            it('removes the added instance', function () {
              expect(model.assocs).toEqual([{id: 1, name: "One"}, {id: 2, name: "Two"}]);
            });
          });

          describe('with local set to true', function () {
            beforeEach(function () {
              model.assocs = [{id: 1, name: "One"}, {id: 2, name: "Two"}];
              model.addAssoc({id: 5, name: "Five"}, true);
            });

            it('does not contact the server', function () {
              httpBackend.verifyNoOutstandingRequest();
            });

            it('adds the instance', function () {
              expect(model.assocs).toEqual([{id: 1, name: "One"}, {id: 2, name: "Two"}, {id: 5, name: "Five"}]);
            });
          });
        });

        describe('removeAssoc(instance, local)', function () {
          describe('on success', function () {
            var obj;

            beforeEach(function () {
              httpBackend.expectDELETE('/objects/3/assocs/1.json').respond(200);
              model.assocs = [{id: 1, name: "One"}, {id: 2, name: "Two"}];
              obj = model.assocs[0];
              model.removeAssoc(obj);
            });

            it('sends a message to the server', function () {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('removes the instance', function () {
              expect(model.assocs).toEqual([{id: 2, name: "Two"}]);
              httpBackend.flush();
              expect(model.assocs).toEqual([{id: 2, name: "Two"}]);
            });

            it('decrements parent_count if present', function() {
              obj.parent_count = 3;
              httpBackend.flush();
              expect(obj.parent_count).toEqual(2);
            });
          });

          describe('on failure', function () {
            beforeEach(function () {
              httpBackend.expectDELETE('/objects/3/assocs/1.json').respond(400);
              model.assocs = [{id: 1, name: "One"}, {id: 2, name: "Two"}];
              model.removeAssoc(model.assocs[0]);
              httpBackend.flush();
            });

            it('restores the removed instance', function () {
              expect(model.assocs).toEqual([{id: 2, name: "Two"}, {id: 1, name: "One"}]);
            });
          });

          describe('with local set to true', function () {
            beforeEach(function () {
              model.assocs = [{id: 1, name: "One"}, {id: 2, name: "Two"}];
              model.removeAssoc(model.assocs[0], true);
            });

            it('does not contact the server', function () {
              httpBackend.verifyNoOutstandingRequest();
            });

            it('removes the instance', function () {
              expect(model.assocs).toEqual([{id: 2, name: "Two"}]);
            });
          });
        });
      });

      describe('before save', function () {
        describe('with no assoc_ids attribute', function () {
          beforeEach(function () {
            model = {
              assocs: [{ id: 2, name: 'blah'}, {name: 'new'}, {id: 4}, {id: 7}]
            };
            extension.beforeSave(model);
          });

          it('sets the assoc_ids attribute', function () {
            expect(model.assoc_ids).toEqual([2, 4, 7]);
          });
        });

        describe('with an assoc_ids attribute', function () {
          beforeEach(function () {
            model = {
              assoc_ids: [6, 4],
              assocs: [{ id: 2, name: 'blah'}, {name: 'new'}, {id: 4}, {id: 7}]
            };
            extension.beforeSave(model);
          });

          it('updates the assoc_ids attribute', function () {
            expect(model.assoc_ids).toEqual([2, 4, 7]);
          });
        });
      });
    });

    describe('with loaded set to true', function () {
      beforeEach(inject(function (association) {

        collection.update = jasmine.createSpy().andCallFake(function (obj) {
          return obj + ' instance';
        });
        extension = association('collection', 'assoc', { loaded: true });
      }));

      describe('with no association field present', function () {
        beforeEach(function () {
          model = { id: 3, name: 'Something' };
          extension(model);
        });

        it('does not update the association collection', function () {
          expect(collection.update).not.toHaveBeenCalled();
        });

        it('leaves the model as it is', function () {
          expect(model).toEqual({ id: 3, name: 'Something' });
        });
      });

      describe('with an association field', function () {
        beforeEach(function () {
          model = { id: 3, name: 'Something',  assocs: ['one', 'two'] };
          extension(model);
        });

        it('updates the association collection with each association', function () {
          expect(collection.update.callCount).toEqual(2);
          expect(collection.update.argsForCall[0][0]).toEqual('one');
          expect(collection.update.argsForCall[1][0]).toEqual('two');
        });

        it('sets the association objects to the returned instances', function () {
          expect(model.assocs).toEqual(['one instance', 'two instance']);
        });
      });
    });

    describe('with mirror set', function () {
      var httpBackend, instance1, instance2;

      beforeEach(inject(function (association, $httpBackend) {

        extension = association('collection', 'assoc', { loaded: true, mirror: 'field' });
        httpBackend = $httpBackend;
        model = { url: function () { return '/objects/3' } };
        extension.setup(model);
        instance1 = { id: 1 }, instance2 = { id: 2 };
        instance2.addField = jasmine.createSpy();
        instance2.removeField = jasmine.createSpy();
      }));

      describe('addAssoc(instance, local)', function () {
        beforeEach(function () {
          model.assocs = [instance1];
        });

        describe('without local set', function () {
          describe('on success', function () {
            beforeEach(function () {
              httpBackend.expectPOST('/objects/3/assocs/2.json').respond(200);
              model.addAssoc(instance2);
            });

            it('does not immediately call the associaions add function', function () {
              expect(instance2.addField).not.toHaveBeenCalled();
            });

            it('calls it on server response', function () {
              httpBackend.flush();
              expect(instance2.addField).toHaveBeenCalledWith(model, true);
            });
          });

          describe('on failure', function () {
            beforeEach(function () {
              httpBackend.expectPOST('/objects/3/assocs/2.json').respond(400);
              model.addAssoc(instance2);
              httpBackend.flush();
            });

            it('makes no call', function () {
              expect(instance2.addField).not.toHaveBeenCalled();
            });
          });
        });

        describe('with local set', function () {
          beforeEach(function () {
            model.addAssoc(instance2, true);
          });

          it('makes no call', function () {
            expect(instance2.addField).not.toHaveBeenCalled();
          });
        });
      });

      describe('removeAssoc(instance, local)', function () {
        beforeEach(function () {
          model.assocs = [instance1, instance2];
        });

        describe('without local set', function () {
          describe('on success', function () {
            beforeEach(function () {
              httpBackend.expectDELETE('/objects/3/assocs/2.json').respond(200);
              model.removeAssoc(instance2);
            });

            it('does not immediately call the associaions remove function', function () {
              expect(instance2.removeField).not.toHaveBeenCalled();
            });

            it('calls it on server response', function () {
              httpBackend.flush();
              expect(instance2.removeField).toHaveBeenCalledWith(model, true);
            });
          });

          describe('on failure', function () {
            beforeEach(function () {
              httpBackend.expectDELETE('/objects/3/assocs/2.json').respond(400);
              model.removeAssoc(instance2);
              httpBackend.flush();
            });

            it('makes no call', function () {
              expect(instance2.removeField).not.toHaveBeenCalled();
            });
          });
        });

        describe('with local set', function () {
          beforeEach(function () {
            model.removeAssoc(instance2, true);
          });

          it('makes no call', function () {
            expect(instance2.removeField).not.toHaveBeenCalled();
          });
        });
      });
    });
  });

  /*---------------- Single association ---------------------*/

  describe('singleAssociation', function () {
    var extension, collection, model, deferred;

    beforeEach(function () {
      collection = {};

      module(function ($provide) {
        $provide.value('collection', collection);
      });
    });

    describe('with defaults', function () {
      beforeEach(inject(function (singleAssociation, $q) {
        deferred = $q.defer();

        // get resolves promises with a string for each instance
        // it rejects the promise for an ID of 6
        collection.get = jasmine.createSpy().andCallFake(function (id) {
          return deferred.promise.
            then(function () {
              if (id == 6) {
                return $q.reject();
              }
              return 'instance ' + id;
            });
        });

        extension = singleAssociation('collection', 'assoc');
      }));

      describe('with no association id field present', function () {
        beforeEach(function () {
          model = { id: 3, name: 'Something' };
          extension(model);
        });

        it('does not get any association models', function () {
          expect(collection.get).not.toHaveBeenCalled();
        });

        it('does nothing to the model', function () {
          expect(model).toEqual({ id: 3, name: 'Something' });
        });
      });

      describe('with an association field', function () {
        beforeEach(function () {
          model = { id: 3, name: 'Something',  assoc_id: 3 };
          extension(model);
        });

        it('gets a model', function () {
          expect(collection.get.callCount).toEqual(1);
          expect(collection.get.argsForCall[0][0]).toEqual(3);
        });

        it('does not add an association yet', function () {
          expect(model.assoc).toBeUndefined;
        });

        it('sets the association field to the resolved instance', inject(function ($rootScope) {
          deferred.resolve();
          $rootScope.$apply();
          expect(model.assoc).toEqual('instance 3');
        }));
      });

      describe('with an invalid association field', function () {
        beforeEach(function () {
          model = { id: 3, name: 'Something',  assoc_id: 6 };
          extension(model);
        });

        it('does not set the association field', inject(function ($rootScope) {
          deferred.resolve();
          $rootScope.$apply();
          expect(model.assoc).toBeUndefined();
        }));
      });

      describe('before save', function () {
        describe('with no assoc_id attribute', function () {
          beforeEach(function () {
            model = {
              assoc: {id: 3, name: 'something'}
            };
            extension.beforeSave(model);
          });

          it('sets the assoc_id attribute', function () {
            expect(model.assoc_id).toEqual(3);
          });
        });

        describe('with an assoc_id attribute', function () {
          beforeEach(function () {
            model = {
              assoc_id: 8,
              assoc: {id: 9}
            };
            extension.beforeSave(model);
          });

          it('updates the assoc_ids attribute', function () {
            expect(model.assoc_id).toEqual(9);
          });
        });

        describe('with an assoc with no id', function () {
          beforeEach(function () {
            model = {
              assoc_id: 8,
              assoc: {name: 'something'}
            };
            extension.beforeSave(model);
          });

          it('removes the assoc_ids attribute', function () {
            expect(model.assoc_id).toBeUndefined();
          });
        });

        describe('with no assoc field', function () {
          beforeEach(function () {
            model = {
              assoc_id: 8
            };
            extension.beforeSave(model);
          });

          it('removes the assoc_ids attribute', function () {
            expect(model.assoc_id).toBeUndefined();
          });
        });
      });
    });

    describe('with polymorphic set', function () {
      var otherCollection;

      beforeEach(function () {
        otherCollection = {};

        module(function ($provide) {
          $provide.value('otherCollection', otherCollection);
        });
      });

      beforeEach(inject(function (singleAssociation, $q) {
        deferred = $q.defer();

        collection.get = jasmine.createSpy().andCallFake(function (id) {
          return deferred.promise.then(function () { return 'instance ' + id; });
        });

        otherCollection.get = jasmine.createSpy().andCallFake(function (id) {
          return deferred.promise.then(function () { return 'otherInstance ' + id; });
        });

        extension = singleAssociation('type_attr', 'assoc', { polymorphic: function(type) {
          return type + 'ection';
        } });
      }));

      describe('with no association id field present', function () {
        beforeEach(function () {
          model = { id: 3, name: 'Something' };
          extension(model);
        });

        it('does nothing to the model', function () {
          expect(model).toEqual({ id: 3, name: 'Something' });
        });
      });

      describe('with an association field of a type collection', function () {
        beforeEach(function () {
          model = { id: 3, name: 'Something',  assoc_id: 3, type_attr: 'coll' };
          extension(model);
        });

        it('gets a model from collection', function () {
          expect(collection.get.callCount).toEqual(1);
          expect(collection.get.argsForCall[0][0]).toEqual(3);
        });

        it('sets the association field to the resolved instance', inject(function ($rootScope) {
          deferred.resolve();
          $rootScope.$apply();
          expect(model.assoc).toEqual('instance 3');
        }));
      });

      describe('with an association field of a type otherCollection', function () {
        beforeEach(function () {
          model = { id: 3, name: 'Something',  assoc_id: 3, type_attr: 'otherColl' };
          extension(model);
        });

        it('gets a model from otherCollection', function () {
          expect(otherCollection.get.callCount).toEqual(1);
          expect(otherCollection.get.argsForCall[0][0]).toEqual(3);
        });

        it('sets the association field to the resolved instance', inject(function ($rootScope) {
          deferred.resolve();
          $rootScope.$apply();
          expect(model.assoc).toEqual('otherInstance 3');
        }));
      });

      describe('with an invalid type', function () {
        beforeEach(function () {
          model = { id: 3, name: 'Something',  assoc_id: 3, type_attr: 'unknownColl' };
        });

        it('raises an error', function () {
          expect(function() {
            extension(model)
          }).toThrow('Unknown provider: unknownCollectionProvider <- unknownCollection');
        });
      });
    });

    describe('with loaded set to true', function () {
      beforeEach(inject(function (singleAssociation) {

        collection.update = jasmine.createSpy().andCallFake(function (obj) {
          return obj + ' instance';
        });
        extension = singleAssociation('collection', 'assoc', { loaded: true });
      }));

      describe('with no association field present', function () {
        beforeEach(function () {
          model = { id: 3, name: 'Something' };
          extension(model);
        });

        it('does not update the association collection', function () {
          expect(collection.update).not.toHaveBeenCalled();
        });

        it('leaves the model as it is', function () {
          expect(model).toEqual({ id: 3, name: 'Something' });
        });
      });

      describe('with an association field', function () {
        beforeEach(function () {
          model = { id: 3, name: 'Something',  assoc: 'something' };
          extension(model);
        });

        it('updates the association collection with each association', function () {
          expect(collection.update.callCount).toEqual(1);
          expect(collection.update.argsForCall[0][0]).toEqual('something');
        });

        it('sets the association object to the returned instance', function () {
          expect(model.assoc).toEqual('something instance');
        });
      });
    });
  });
});