'use strict';

describe('Model module', function() {  
  beforeEach(module('journals.model'));

  describe('model', function() {
    var model, httpBackend;

    beforeEach(inject(function($httpBackend, _model_) {
      httpBackend = $httpBackend;
      model = _model_('object', '/objects');
    }));

    describe('getPath()', function() {
      it('returns the passed path', function() {
        expect(model.getPath()).toEqual('/objects');
      });
    });

    describe('create()', function() {
      var instance;

      describe('for a new instance', function() {
        beforeEach(function() {
          instance = model.create({name: 'Something', field: 'Some value'})
        });

        it('copies input data', function() {
          expect(instance.name).toEqual('Something');
          expect(instance.field).toEqual('Some value');
        });

        it('sets up the save, updateField and delete functions', function() {
          expect(angular.isFunction(instance.save)).toEqual(true);
          expect(angular.isFunction(instance.updateField)).toEqual(true);
          expect(angular.isFunction(instance.delete)).toEqual(true);
        });
      });

      describe('for an existing instance', function() {
        beforeEach(function() {
          instance = model.create({id: 5, name: 'Something', field: 'Some value'})
        });

        it('copies input data', function() {
          expect(instance.id).toEqual(5);
          expect(instance.name).toEqual('Something');
          expect(instance.field).toEqual('Some value');
        });

        it('sets up the save, updateField and delete functions', function() {
          expect(angular.isFunction(instance.save)).toEqual(true);
          expect(angular.isFunction(instance.updateField)).toEqual(true);
          expect(angular.isFunction(instance.delete)).toEqual(true);
        });
      });
    });
  
    describe('instance functions:', function() {
      
      describe('save()', function() {
        var instance;

        describe('for a new instance', function() {
          beforeEach(function() {
            instance = model.create();
          });

          describe('on success', function() {
            beforeEach(function() {
              httpBackend.expectPOST('/objects', { object: { name: 'New model' }}).respond({ id: 1, name: 'Something' });
              instance.name = 'New model'
              instance.save();
            });

            it('sends a message to the server', function() {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('updates the instance with returned data', function() {
              httpBackend.flush();
              expect(instance.name).toEqual('Something');
              expect(instance.id).toEqual(1);
            });
          });

          describe('on failure', function() {
            beforeEach(function() {
              httpBackend.expectPOST('/objects').respond(400, 'Some error');
              instance.name = 'New model'
              instance.save();
            });

            it('calls delete', function() {
              spyOn(instance, 'delete');
              httpBackend.flush();
              expect(instance.delete).toHaveBeenCalled();
            });
          });
        });
      

        describe('for an existing instance', function() {
          beforeEach(function() {
            instance = model.create({id: 5, name: 'Some name'});
          });

          describe('on success', function() {
            beforeEach(function() {
              httpBackend.expectPUT('/objects/5', { object: { name: 'Some name' }}).respond({ id: 5, name: 'Something' });
              instance.save();
            });

            it('sends a message to the server', function() {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('updates the instance with returned data', function() {
              httpBackend.flush();
              expect(instance.name).toEqual('Something');
            });
          });

          describe('on failure', function() {
            beforeEach(function() {
              httpBackend.expectPUT('/objects/5').respond(400, 'Some error');
              spyOn(instance, 'delete');
              instance.save();
            });

            it('does nothing', function() {
              httpBackend.flush();
              expect(instance.delete).not.toHaveBeenCalled();
              expect(instance.name).toEqual('Some name');
            });
          });
        });
      });

      describe('updateField(field, value)', function() {
        var instance

        describe('for a new instance', function() {
          beforeEach(function() {
            instance = model.create();
          });

          describe('with a blank value', function() {
            beforeEach(function() {
              spyOn(instance, 'save');
              spyOn(instance, 'delete');
              instance.updateField('name', '');
            });

            it('does not call save', function() {
              expect(instance.save).not.toHaveBeenCalled();
            });

            it('calls delete', function() {
              expect(instance.delete).toHaveBeenCalled();
            })
          });

          describe('with a value', function() {
            beforeEach(function() {
              spyOn(instance, 'save');
              instance.updateField('name', 'New name');
            });

            it('sets the field', function() {
              expect(instance.name).toEqual('New name');
            });

            it('calls save', function() {
              expect(instance.save).toHaveBeenCalled();
            });
          });
        });
        
        describe('for an existing instance', function() {
          beforeEach(function() {
            instance = model.create({ id: 5, name: 'Some name', field: 'Something' });
          });

          describe('with an unchanged value', function() {
            beforeEach(function() {
              instance.updateField('name', 'Some name');
            });

            it('does nothing', function() {
              expect(instance.name).toEqual('Some name');
            });
          });

          describe('on success', function() {
            beforeEach(function() {
              httpBackend.expectPUT('/objects/5', { object: { name: 'Changed name' } }).
                respond({ id: 5, name: 'Changed again', field: 'Changed too' });
              instance.updateField('name', 'Changed name');
            });

            it('sends a message to the server', function() {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('updates the field', function() {
              expect(instance.name).toEqual('Changed name');
            });

            it('loads data from the server response', function() {
              httpBackend.flush();
              expect(instance.name).toEqual('Changed again');
              expect(instance.field).toEqual('Changed too');
            });
          });

          describe('on failure', function() {
            beforeEach(function() {
              httpBackend.expectPUT('/objects/5').respond(400);
              instance.updateField('name', 'Changed name');
            });

            it('restores the old field value', function() {
              httpBackend.flush();
              expect(instance.name).toEqual('Some name');
            });
          });
        });
      });

      describe('delete()', function() {
        var instance

        describe('for a new instance', function() {
          beforeEach(function() {
            instance = model.create();
          });

          it('sets deleted for the instance', function() {
            instance.delete();
            expect(instance.deleted).toEqual(true);
          });
        });

        describe('for an existing instance', function() {
          beforeEach(function() {
            instance = model.create({ id: 5, name: 'Some name' });
          });

          describe('on success', function() {
            beforeEach(function() {
              httpBackend.expectDELETE('/objects/5').respond(200);
              instance.delete();
            });

            it('sends a message to the server', function() {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('sets deleted', function() {
              expect(instance.deleted).toEqual(true);
              httpBackend.flush();
              expect(instance.deleted).toEqual(true);
            });
          });

          describe('on failure', function() {
            beforeEach(function() {
              httpBackend.expectDELETE('/objects/5').respond(400);
              instance.delete();
            });

            it('removes deleted', function() {
              httpBackend.flush();
              expect(instance.deleted).toBeUndefined();
            });
          });
        });
      });
    });

    describe('with extensions set', function() {
      var instance, extension1, extension2;

      beforeEach(inject(function(_model_) {
        extension1 = jasmine.createSpy().andCallFake(function(model) {
          model.ext1 = true;
          model.last = 'ext1';
        });
        
        extension2 = jasmine.createSpy().andCallFake(function(model) {
          model.ext2 = true;
          model.last = 'ext2';
        });

        model = _model_('object', '/objects', {
          extensions: [extension1, extension2]
        });
        instance = model.create({id: 3, name: 'Something', ext1: false});
      }));

      it('calls each extension on creation', function() {
        expect(extension1).toHaveBeenCalledWith(instance);
        expect(extension2).toHaveBeenCalledWith(instance);
      });

      it('applies each change to the model', function() {
        expect(instance.ext1).toEqual(true);
        expect(instance.ext2).toEqual(true);
      });

      it('preserves untouched model data', function() {
        expect(instance.name).toEqual('Something');
        expect(instance.id).toEqual(3);
      });

      it('calls the extensions in order', function() {
        expect(instance.last).toEqual('ext2');
      });

      describe('on save', function() {
        beforeEach(function() {
          extension1.reset();
          extension2.reset();

          extension2.formatHttpData = jasmine.createSpy().andCallFake(function(data) {
            delete data.ext1;
            delete data.ext2;
            delete data.last;
            data.formatted = 'yes';
          });

          httpBackend.expectPUT('/objects/3', {
            object: {
              name: 'Something', formatted: 'yes'
            }
          }).respond({id: 3, name: 'Something Else', last: 'server'});

          instance.save();
        });

        it('calls the extensions formatHttpData functions immediately', function() {
          expect(extension2.formatHttpData).toHaveBeenCalled();
        });

        it('it does not immediately call the extensions', function() {
          expect(extension1).not.toHaveBeenCalled();
          expect(extension2).not.toHaveBeenCalled();
        });

        it('calls the extensions on server response', function() {
          httpBackend.flush();
          expect(extension1).toHaveBeenCalledWith(instance);
          expect(extension2).toHaveBeenCalledWith(instance);
        });

        it('applies the extensions to the received data', function() {
          httpBackend.flush();
          expect(instance).toEqualData({id: 3, name: 'Something Else', last: 'ext2', ext1: true, ext2: true, formatted: 'yes'})
        });
      });
    });
  });

  
  describe('editableFieldsExtension', function() {
    var extension;

    describe('with primaryField set', function() {
      beforeEach(inject(function(editableFieldsExtension) {
        extension = editableFieldsExtension('field');
      }));

      it('adds an empty editing object to a model', function() {
        var model = { id: 1, name: "Something", field: "Value" };
        extension(model);
        expect(model).toEqualData({ id: 1, name: "Something", field: "Value", editing: {} })
      });

      it('adds an editing object, with the primary field set, to a new model', function() {
        var model = { name: "Something", field: "Value" };
        extension(model);
        expect(model).toEqualData({ name: "Something", field: "Value", editing: { field: true } })
      });
    });

    describe('without primaryField set', function() {
      beforeEach(inject(function(editableFieldsExtension) {
        extension = editableFieldsExtension();
      }));

      it('adds an empty editing object to a model', function() {
        var model = { id: 1, name: "Something", field: "Value" };
        extension(model);
        expect(model).toEqualData({ id: 1, name: "Something", field: "Value", editing: {} })
      });

      it('adds an empty editing object to a new model', function() {
        var model = { name: "Something", field: "Value" };
        extension(model);
        expect(model).toEqualData({ name: "Something", field: "Value", editing: {} })
      });
    });

    describe('formatHttpData()', function() {
      beforeEach(inject(function(editableFieldsExtension) {
        extension = editableFieldsExtension();
      }));

      it('removes the editing object', function() {
        var data = {field: 'value', editing: {}}
        extension.formatHttpData(data)
        expect(data).toEqualData({field: 'value'});
      });
    });
  });
});

