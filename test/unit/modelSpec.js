'use strict';

describe('Model module', function () {
  beforeEach(module('journals.model'));

  describe('model', function () {
    var model, httpBackend, instance, rootScope;

    beforeEach(inject(function ($httpBackend, _model_, $rootScope) {
      httpBackend = $httpBackend;
      rootScope = $rootScope;
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
      var promise, success, error;

      beforeEach(function () {
        success = jasmine.createSpy();
        error = jasmine.createSpy();
      });

      describe('isNew()', function () {
        describe('for a new instance', function () {
          beforeEach(function () {
            instance = model.create();
          });

          it('returns true', function () {
            expect(instance.isNew()).toEqual(true);
          });
        });

        describe('for an existing instance', function () {
          beforeEach(function () {
            instance = model.create({id: 5, name: 'Some name'});
          });

          it('returns false', function () {
            expect(instance.isNew()).toEqual(false);
          });
        });
      });

      describe('load()', function () {
        describe('without deleted set', function () {
          beforeEach(function () {
            instance = model.create({id: 5, name: 'Something', field: 'Some value'});
            instance.load({id: 5, name: 'Something different', other_field: 67, func: function () {}});
          });

          it('copies passed data', function () {
            expect(instance).toEqualData({id: 5, name: 'Something different', other_field: 67, field: 'Some value'});
          });

          it('ignores functions', function () {
            expect(instance.func).toBeUndefined();
          });
        });

        describe('with deleted set', function () {
          beforeEach(function () {
            instance = model.create({name: 'Something', field: 'Some value', deleted: true});
          });

          describe('when data with an id is loaded', function () {
            beforeEach(function () {
              instance.load({id: 8, name: 'Something different', other_field: 67, func: function () {}});
            });

            it('removes deleted', function () {
              expect(instance).toEqualData({id: 8, name: 'Something different', other_field: 67, field: 'Some value'});
            });
          });

          describe('when data without an id is loaded', function () {
            beforeEach(function () {
              instance.load({name: 'Something different', other_field: 67, func: function () {}});
            });

            it('does not remove deleted', function () {
              expect(instance).toEqualData({name: 'Something different', other_field: 67, field: 'Some value', deleted: true});
            });
          });
        });
      });

      describe('save()', function () {
        describe('for a new instance', function () {
          beforeEach(function () {
            instance = model.create();
          });

          describe('on success', function () {
            beforeEach(function () {
              httpBackend.expectPOST('/objects.json', { object: { name: 'New model' }}).respond({ id: 1, name: 'Something' });
              instance.name = 'New model'
              promise = instance.save();
              promise.then(success, error);
            });

            it('sends a message to the server', function () {
              httpBackend.verifyNoOutstandingExpectation();
            });

            describe('on response', function () {
              beforeEach(function () {
                httpBackend.flush();
              });

              it('updates the instance with returned data', function () {
                expect(instance.name).toEqual('Something');
                expect(instance.id).toEqual(1);
              });

              it('resolves the promise', function () {
                expect(success).toHaveBeenCalledWith(instance);
              });
            });
          });

          describe('on failure', function () {
            beforeEach(function () {
              httpBackend.expectPOST('/objects.json').respond(400, 'Some error');
              instance.name = 'New model'
              spyOn(instance, 'delete');
              promise = instance.save();
              promise.then(success, error);
              httpBackend.flush();
            });

            it('calls delete', function () {
              expect(instance.delete).toHaveBeenCalled();
            });

            it('rejects the promise', function () {
              expect(error).toHaveBeenCalled();
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
              promise = instance.save();
              promise.then(success, error)
            });

            it('sends a message to the server', function () {
              httpBackend.verifyNoOutstandingExpectation();
            });

            describe('on response', function () {
              beforeEach(function () {
                httpBackend.flush();
              });

              it('updates the instance with returned data', function () {
                expect(instance.name).toEqual('Something');
              });

              it('resolves the promise', function () {
                expect(success).toHaveBeenCalledWith(instance);
              });
            });
          });

          describe('on failure', function () {
            beforeEach(function () {
              httpBackend.expectPUT('/objects/5.json').respond(400, 'Some error');
              spyOn(instance, 'delete');
              promise = instance.save();
              promise.then(success, error);
              httpBackend.flush();
            });

            it('does nothing to the instance', function () {
              expect(instance.delete).not.toHaveBeenCalled();
              expect(instance.name).toEqual('Some name');
            });

            it('rejects the promise', function () {
              expect(error).toHaveBeenCalled();
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
              promise = instance.updateField('name', '');
              promise.then(success, error);
            });

            it('does not call save', function () {
              expect(instance.save).not.toHaveBeenCalled();
            });

            it('calls delete', function () {
              expect(instance.delete).toHaveBeenCalled();
            });

            it('rejects the promise', function () {
              rootScope.$apply();
              expect(error).toHaveBeenCalled();
            });
          });

          describe('with a value', function () {
            beforeEach(function () {
              spyOn(instance, 'save').andReturn('save promise');
              promise = instance.updateField('name', 'New name');
            });

            it('sets the field', function () {
              expect(instance.name).toEqual('New name');
            });

            it('calls save', function () {
              expect(instance.save).toHaveBeenCalled();
            });

            it('returns the save promise', function () {
              expect(promise).toEqual('save promise');
            });
          });
        });

        describe('for an existing instance', function () {
          beforeEach(function () {
            instance = model.create({ id: 5, name: 'Some name', field: 'Something' });
          });

          describe('with an unchanged value', function () {
            beforeEach(function () {
              promise = instance.updateField('name', 'Some name');
              promise.then(success, error);
            });

            it('does nothing to the instance', function () {
              expect(instance.name).toEqual('Some name');
            });

            it('resolves the promise with the instance', function () {
              rootScope.$apply();
              expect(success).toHaveBeenCalledWith(instance);
            })
          });

          describe('on success', function () {
            beforeEach(function () {
              httpBackend.expectPUT('/objects/5.json', { object: { name: 'Changed name' } }).
                respond({ id: 5, name: 'Changed again', field: 'Changed too' });
              promise = instance.updateField('name', 'Changed name');
              promise.then(success, error)
            });

            it('sends a message to the server', function () {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('updates the field', function () {
              expect(instance.name).toEqual('Changed name');
            });

            describe('on response', function() {
              beforeEach(function () {
                httpBackend.flush();
              });

              it('loads data from the server response', function () {
                expect(instance.name).toEqual('Changed again');
                expect(instance.field).toEqual('Changed too');
              });

              it('resolves the promise with the instance', function () {
                expect(success).toHaveBeenCalledWith(instance);
              });
            });
          });

          describe('on failure', function () {
            beforeEach(function () {
              httpBackend.expectPUT('/objects/5.json').respond(400);
              promise = instance.updateField('name', 'Changed name');
              promise.then(success, error);
              httpBackend.flush();
            });

            it('restores the old field value', function () {
              expect(instance.name).toEqual('Some name');
            });

            it('rejects the promise', function () {
              expect(error).toHaveBeenCalled();
            });
          });
        });
      });

      describe('delete()', function () {
        describe('for a new instance', function () {
          beforeEach(function () {
            instance = model.create();
            promise = instance.delete();
            promise.then(success, error);
          });

          it('sets deleted for the instance', function () {
            expect(instance.deleted).toEqual(true);
          });

          it('resolves the promise', function () {
            rootScope.$apply();
            expect(success).toHaveBeenCalledWith(instance);
          });
        });

        describe('for an existing instance', function () {
          beforeEach(function () {
            instance = model.create({ id: 5, name: 'Some name' });
          });

          describe('on success', function () {
            beforeEach(function () {
              httpBackend.expectDELETE('/objects/5.json').respond(200);
              promise = instance.delete();
              promise.then(success, error);
            });

            it('sends a message to the server', function () {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('sets deleted', function () {
              expect(instance.deleted).toEqual(true);
              httpBackend.flush();
              expect(instance.deleted).toEqual(true);
            });

            it('resolves the promise', function () {
              httpBackend.flush();
              expect(success).toHaveBeenCalledWith(instance);
            });
          });

          describe('on failure', function () {
            beforeEach(function () {
              httpBackend.expectDELETE('/objects/5.json').respond(400);
              promise = instance.delete();
              promise.then(success, error);
              httpBackend.flush();
            });

            it('removes deleted', function () {
              expect(instance.deleted).toBeUndefined();
            });

            it('rejects the promise', function () {
              expect(error).toHaveBeenCalled();
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

        extension1.beforeSave = jasmine.createSpy().andCallFake(function (model) {
          model.name = model.name + ' formatted';
          model.last = 'ext1-save';
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
            object: { name: 'Something formatted' }
          }).respond({id: 3, name: 'Something Else', last: 'server'});

          instance.save();
        });

        it('calls the extension beforeSave functions', function () {
          expect(extension1.beforeSave).toHaveBeenCalledWith(instance);
        });

        it('allows the beforeSave extensions to modify the instance', function () {
          expect(instance.last).toEqual('ext1-save');
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

    describe('with hasParent set', function () {
      beforeEach(inject(function (_model_) {
        model = _model_('object', '/objects', { hasParent: true })
      }));

      describe('without _parent', function () {
        beforeEach(function () {
          instance = model.create();
        });

        it('raises an error on save()', function() {
          expect(instance.save).toThrow('_parent model not present');
        });

        it('raises an error on delete()', function() {
          expect(instance.save).toThrow('_parent model not present');
        });
      });

      describe('with a new _parent', function () {
        beforeEach(function () {
          instance = model.create({
            id: 5,
            _parent: {
              isNew: function () { return true },
              url: function () { return '/parent/path' }
            }
          });
        });

        it('raises an error on save()', function () {
          expect(instance.save).toThrow('_parent model not saved');
        });

        it('raises an error on delete()', function () {
          expect(instance.save).toThrow('_parent model not saved');
        });
      });

      describe('with an existing _parent', function () {
        beforeEach(function () {
          instance = model.create({
            id: 5,
            _parent: {
              isNew: function () { return false },
              url: function () { return '/parent/path' }
            }
          });
        });

        it('sends a PUT request to the correct path for save', function () {
          httpBackend.expectPUT('/parent/path/objects/5.json').respond(200);
          instance.save();
          httpBackend.verifyNoOutstandingExpectation();
        });

        it('sends a PUT request to the correct path for save, for a new instance', function () {
          delete instance.id;
          httpBackend.expectPOST('/parent/path/objects.json').respond(200);
          instance.save();
          httpBackend.verifyNoOutstandingExpectation();
        });

        it('sends a DELETE request to the correct path for delete', function () {
          httpBackend.expectDELETE('/parent/path/objects/5.json').respond(200);
          instance.delete();
          httpBackend.verifyNoOutstandingExpectation();
        });
      });
    });
  });
});

