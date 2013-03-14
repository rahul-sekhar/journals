'use strict';

describe('Groups module', function() {  
  beforeEach(module('journals.groups'));

  /*---------- Groups service -----------------*/

  describe('Groups', function() {
    var collection, model, Groups, editableFieldsExtension;

    beforeEach(module(function($provide) {
      model = jasmine.createSpy().andReturn('model');
      collection = jasmine.createSpy().andReturn('collection');
      editableFieldsExtension = jasmine.createSpy().andReturn('editableFieldsExtension');
      $provide.value('model', model);
      $provide.value('collection', collection);
      $provide.value('editableFieldsExtension', editableFieldsExtension);
    }));

    beforeEach(inject(function(_Groups_) {
      Groups = _Groups_;
    }));

    it('sets the model name to "group"', function() {
      expect(model.mostRecentCall.args[0]).toEqual('group');
    });

    it('sets the model url to "/groups"', function() {
      expect(model.mostRecentCall.args[1]).toEqual('/groups');
    });

    it('adds the editableFieldsExtension, setting the primary field to name', function() {
      expect(editableFieldsExtension).toHaveBeenCalledWith('name');
      expect(model.mostRecentCall.args[2]).toEqual({extensions: ['editableFieldsExtension']});
    });

    it('calls the collection with the model object', function() {
      expect(collection).toHaveBeenCalledWith('model');
    });

    it('returns the collection object', function() {
      expect(Groups).toEqual('collection');
    });
  });

  /*---------- Groups controller --------------------*/
  describe('GroupsCtrl', function() {
    var scope, ctrl, Groups;

    beforeEach(inject(function($rootScope, $controller, $injector) {
      Groups = { all: jasmine.createSpy('Groups.all').
        andReturn([{id: 1, name: 'One'}, {id: 3, name: 'Three'}]) };

      scope = $rootScope.$new();
      ctrl = $controller('GroupsCtrl', { $scope: scope, Groups: Groups });
    }));

    it('sets groups to the value of Groups.all()', function() {
      expect(Groups.all).toHaveBeenCalled();
      expect(scope.groups).toEqual([{id: 1, name: 'One'}, {id: 3, name: 'Three'}]);
    });

    describe('add()', function() {
      beforeEach(function() {
        Groups.add = jasmine.createSpy('Groups.add');
        scope.add();
      });

      it('adds alls Groups.add()', function() {
        expect(Groups.add).toHaveBeenCalled();
      });
    });
  });
});

