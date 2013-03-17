'use strict';

describe('Model module', function () {
  beforeEach(module('journals.model'));

  describe('model', function () {
    var model, httpBackend, instance;

    beforeEach(inject(function ($httpBackend, _model_) {
      httpBackend = $httpBackend;
      model = _model_('object', '/objects');
    }));

    describe('getPath()', function () {
      it('returns the passed path', function () {
        expect(model.getPath()).toEqual('/objects');
      });
    });

    describe('create()', function () {
      describe('for a new instance', function () {
        beforeEach(function () {
          instance = model.create({name: 'Something', field: 'Some value'})
        });

        it('copies input data', function () {
          expect(instance.name).toEqual('Something');
          expect(instance.field).toEqual('Some value');
        });

        it('sets up the save, updateField and delete functions', function () {
          expect(angular.isFunction(instance.save)).toEqual(true);
          expect(angular.isFunction(instance.updateField)).toEqual(true);
          expect(angular.isFunction(instance.delete)).toEqual(true);
        });
      });

      describe('for an existing instance', function () {
        beforeEach(function () {
          instance = model.create({id: 5, name: 'Something', field: 'Some value'})
        });

        it('copies input data', function () {
          expect(instance.id).toEqual(5);
          expect(instance.name).toEqual('Something');
          expect(instance.field).toEqual('Some value');
        });

        it('sets up the save, updateField and delete functions', function () {
          expect(angular.isFunction(instance.save)).toEqual(true);
          expect(angular.isFunction(instance.updateField)).toEqual(true);
          expect(angular.isFunction(instance.delete)).toEqual(true);
        });
      });
    });

    describe('instance functions:', function () {

      describe('load()', function () {
        beforeEach(function () {
          instance = model.create({id: 5, name: 'Something', field: 'Some value'})
          instance.load({id: 5, name: 'Something different', other_field: 67, func: function () {}});
        });

        it('copies passed data', function () {
          expect(instance).toEqualData({id: 5, name: 'Something different', other_field: 67, field: 'Some value'});
        });

        it('ignores functions', function () {
          expect(instance.func).toBeUndefined();
        });
      });

      describe('save()', function () {
        var instance;

        describe('for a new instance', function () {
          beforeEach(function () {
            instance = model.create();
          });

          describe('on success', function () {
            beforeEach(function () {
              httpBackend.expectPOST('/objects.json', { object: { name: 'New model' }}).respond({ id: 1, name: 'Something' });
              instance.name = 'New model'
              instance.save();
            });

            it('sends a message to the server', function () {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('updates the instance with returned data', function () {
              httpBackend.flush();
              expect(instance.name).toEqual('Something');
              expect(instance.id).toEqual(1);
            });
          });

          describe('on failure', function () {
            beforeEach(function () {
              httpBackend.expectPOST('/objects.json').respond(400, 'Some error');
              instance.name = 'New model'
              instance.save();
            });

            it('calls delete', function () {
              spyOn(instance, 'delete');
              httpBackend.flush();
              expect(instance.delete).toHaveBeenCalled();
            });
          });
        });


        describe('for an existing instance', function () {
          beforeEach(function () {
            instance = model.create({id: 5, name: 'Some name'});
          });

          describe('on success', function () {
            beforeEach(function () {
              httpBackend.expectPUT('/objects/5.json', { object: { name: 'Some name' }}).respond({ id: 5, name: 'Something' });
              instance.save();
            });

            it('sends a message to the server', function () {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('updates the instance with returned data', function () {
              httpBackend.flush();
              expect(instance.name).toEqual('Something');
            });
          });

          describe('on failure', function () {
            beforeEach(function () {
              httpBackend.expectPUT('/objects/5.json').respond(400, 'Some error');
              spyOn(instance, 'delete');
              instance.save();
            });

            it('does nothing', function () {
              httpBackend.flush();
              expect(instance.delete).not.toHaveBeenCalled();
              expect(instance.name).toEqual('Some name');
            });
          });
        });
      });

      describe('updateField(field, value)', function () {
        describe('for a new instance', function () {
          beforeEach(function () {
            instance = model.create();
          });

          describe('with a blank value', function () {
            beforeEach(function () {
              spyOn(instance, 'save');
              spyOn(instance, 'delete');
              instance.updateField('name', '');
            });

            it('does not call save', function () {
              expect(instance.save).not.toHaveBeenCalled();
            });

            it('calls delete', function () {
              expect(instance.delete).toHaveBeenCalled();
            })
          });

          describe('with a value', function () {
            beforeEach(function () {
              spyOn(instance, 'save');
              instance.updateField('name', 'New name');
            });

            it('sets the field', function () {
              expect(instance.name).toEqual('New name');
            });

            it('calls save', function () {
              expect(instance.save).toHaveBeenCalled();
            });
          });
        });

        describe('for an existing instance', function () {
          beforeEach(function () {
            instance = model.create({ id: 5, name: 'Some name', field: 'Something' });
          });

          describe('with an unchanged value', function () {
            beforeEach(function () {
              instance.updateField('name', 'Some name');
            });

            it('does nothing', function () {
              expect(instance.name).toEqual('Some name');
            });
          });

          describe('on success', function () {
            beforeEach(function () {
              httpBackend.expectPUT('/objects/5.json', { object: { name: 'Changed name' } }).
                respond({ id: 5, name: 'Changed again', field: 'Changed too' });
              instance.updateField('name', 'Changed name');
            });

            it('sends a message to the server', function () {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('updates the field', function () {
              expect(instance.name).toEqual('Changed name');
            });

            it('loads data from the server response', function () {
              httpBackend.flush();
              expect(instance.name).toEqual('Changed again');
              expect(instance.field).toEqual('Changed too');
            });
          });

          describe('on failure', function () {
            beforeEach(function () {
              httpBackend.expectPUT('/objects/5.json').respond(400);
              instance.updateField('name', 'Changed name');
            });

            it('restores the old field value', function () {
              httpBackend.flush();
              expect(instance.name).toEqual('Some name');
            });
          });
        });
      });

      describe('delete()', function () {
        describe('for a new instance', function () {
          beforeEach(function () {
            instance = model.create();
          });

          it('sets deleted for the instance', function () {
            instance.delete();
            expect(instance.deleted).toEqual(true);
          });
        });

        describe('for an existing instance', function () {
          beforeEach(function () {
            instance = model.create({ id: 5, name: 'Some name' });
          });

          describe('on success', function () {
            beforeEach(function () {
              httpBackend.expectDELETE('/objects/5.json').respond(200);
              instance.delete();
            });

            it('sends a message to the server', function () {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('sets deleted', function () {
              expect(instance.deleted).toEqual(true);
              httpBackend.flush();
              expect(instance.deleted).toEqual(true);
            });
          });

          describe('on failure', function () {
            beforeEach(function () {
              httpBackend.expectDELETE('/objects/5.json').respond(400);
              instance.delete();
            });

            it('removes deleted', function () {
              httpBackend.flush();
              expect(instance.deleted).toBeUndefined();
            });
          });
        });
      });
    });

    describe('with saveFields set', function () {
      beforeEach(inject(function (_model_) {
        model = _model_('object', '/objects', {
          saveFields: ['field1', 'field2', 'field4']
        });
        instance = model.create({id: 3, name: 'Something', field2: 'val2', field3: 'val3', field4: 'val4'});
      }));

      it('only sends the set fields to the server', function () {
        httpBackend.expectPUT('/objects/3.json', {object: { field2: 'val2', field4: 'val4' }}).respond(200);
        instance.save();
        httpBackend.verifyNoOutstandingExpectation();
      });
    });

    describe('with defaultData set', function () {
      beforeEach(inject(function (_model_) {
        model = _model_('object', '/objects', {
          defaultData: { some: 'data' }
        });
      }));

      it('sets the default data for a new model', function () {
        instance = model.create();
        expect(instance).toEqualData({ some: 'data' });
      });

      it('sets the default data for an existing model', function () {
        instance = model.create({ id: 1, name: 'Something' });
        expect(instance).toEqualData({ id: 1, name: 'Something', some: 'data' });
      });

      it('allows the default data to be overwritten', function () {
        instance = model.create({ id: 1, name: 'Something', some: 'thing else' });
        expect(instance).toEqualData({ id: 1, name: 'Something', some: 'thing else' });
      });
    });

    describe('with extensions set', function () {
      var extension1, extension2;

      beforeEach(inject(function (_model_) {
        extension1 = jasmine.createSpy().andCallFake(function (model) {
          model.ext1 = true;
          model.last = 'ext1';
        });

        extension2 = jasmine.createSpy().andCallFake(function (model) {
          model.ext2 = true;
          model.last = 'ext2';
        });

        extension2.setup = jasmine.createSpy().andCallFake(function (model) {
          model.ext2setup = function () {};
          model.last = 'ext2setup';
        });

        model = _model_('object', '/objects', {
          extensions: [extension1, extension2]
        });
        instance = model.create({id: 3, name: 'Something', ext1: false});
      }));

      it('calls each extension on creation', function () {
        expect(extension1).toHaveBeenCalledWith(instance);
        expect(extension2).toHaveBeenCalledWith(instance);
      });

      it('calls each extension setup on creation', function () {
        expect(extension2.setup).toHaveBeenCalledWith(instance);
      });

      it('applies each change to the model', function () {
        expect(instance.ext1).toEqual(true);
        expect(instance.ext2).toEqual(true);
        expect(instance.ext2setup).toBeDefined();
      });

      it('preserves untouched model data', function () {
        expect(instance.name).toEqual('Something');
        expect(instance.id).toEqual(3);
      });

      it('calls the extensions in order', function () {
        expect(instance.last).toEqual('ext2');
      });

      describe('on load', function () {
        beforeEach(function () {
          extension1.reset();
          extension2.reset();
          extension2.setup.reset();
          instance.load({});
        });

        it('calls each extension', function () {
          expect(extension1).toHaveBeenCalledWith(instance);
          expect(extension2).toHaveBeenCalledWith(instance);
        });

        it('does not call setup functions', function () {
          expect(extension2.setup).not.toHaveBeenCalled();
        });
      });

      describe('on save', function () {
        beforeEach(function () {
          extension1.reset();
          extension2.reset();
          extension2.setup.reset();

          httpBackend.expectPUT('/objects/3.json', {
            object: { name: 'Something' }
          }).respond({id: 3, name: 'Something Else', last: 'server'});

          instance.save();
        });

        it('it does not immediately call the extensions', function () {
          expect(extension1).not.toHaveBeenCalled();
          expect(extension2).not.toHaveBeenCalled();
        });

        describe('on response', function () {
          beforeEach(function () {
            httpBackend.flush();
          });

          it('calls the extensions', function () {
            expect(extension1).toHaveBeenCalledWith(instance);
            expect(extension2).toHaveBeenCalledWith(instance);
          });

          it('does not call setup functions', function () {
            expect(extension2.setup).not.toHaveBeenCalled();
          });

          it('applies the extensions to the received data', function () {
            expect(instance).toEqualData({id: 3, name: 'Something Else', last: 'ext2', ext1: true, ext2: true})
          });
        });
      });
    });
  });


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
          var result;

          beforeEach(function () {
            collection.all = jasmine.createSpy().andReturn([1,5,6,7]);
            model.assocs = [5,6,8];
            result = model.remainingAssocs();
          });

          it('calls collection.all()', function () {
            expect(collection.all).toHaveBeenCalled();
          });

          it('returns the remaining instances', function () {
            expect(result).toEqual([1,7]);
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

