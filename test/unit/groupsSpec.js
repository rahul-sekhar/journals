'use strict';

describe('Groups module', function() {
  beforeEach(module('journals.groups'));

  /*---------- Groups service -----------------*/

  describe('Groups', function() {
    var collection, model, Groups;

    beforeEach(module(function($provide) {
      model = jasmine.createSpy().andReturn('model');
      collection = jasmine.createSpy().andReturn('collection');
      $provide.value('model', model);
      $provide.value('collection', collection);
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

    it('calls the collection with the model object', function() {
      expect(collection).toHaveBeenCalledWith('model');
    });

    it('returns the collection object', function() {
      expect(Groups).toEqual('collection');
    });
  });

  /*---------- Groups controller --------------------*/
  describe('GroupsCtrl', function() {
    var scope, ctrl, Groups, timeout;

    beforeEach(inject(function($rootScope, $controller, $injector, $timeout) {
      timeout = $timeout;

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
        Groups.add = jasmine.createSpy('Groups.add').andReturn('group');
        scope.add();
      });

      it('adds alls Groups.add()', function() {
        expect(Groups.add).toHaveBeenCalled();
      });

      it('sets _edit to name for the new object', function() {
        expect(Groups.add).toHaveBeenCalledWith({ _edit: 'name' });
      });
    });
  });
});

