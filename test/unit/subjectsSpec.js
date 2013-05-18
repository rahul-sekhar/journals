'use strict';

describe('subjects module', function () {
  beforeEach(module('journals.subjects'));

  /*------------------ Subjects collection ----------------------*/
  describe('Subjects', function() {
    var collection, model, Subjects;

    beforeEach(module(function($provide) {
      model = jasmine.createSpy().andReturn('model');
      collection = jasmine.createSpy().andReturn('collection');
      $provide.value('model', model);
      $provide.value('collection', collection);
    }));

    beforeEach(inject(function(_Subjects_) {
      Subjects = _Subjects_;
    }));

    it('sets the model name', function() {
      expect(model.mostRecentCall.args[0]).toEqual('subject');
    });

    it('sets the model url', function() {
      expect(model.mostRecentCall.args[1]).toEqual('/academics/subjects');
    });

    it('calls the collection with the model object', function() {
      expect(collection).toHaveBeenCalledWith('model');
    });

    it('returns the collection object', function() {
      expect(Subjects).toEqual('collection');
    });
  });


  /*------------------ Subjects controller ----------------------*/
  describe('SubjectsCtrl', function () {
    var scope, httpBackend, Subjects, confirm;

    beforeEach(inject(function ($rootScope, $httpBackend, $controller, _confirm_) {
      confirm = _confirm_;
      scope = $rootScope.$new();
      httpBackend = $httpBackend;

      Subjects = { all: jasmine.createSpy('Subjects.all').
        andReturn([{id: 1, name: 'One'}, {id: 3, name: 'Three'}]) };

      $controller('SubjectsCtrl', { $scope: scope, Subjects: Subjects });
    }));

    it('sets pageTitle', function () {
      expect(scope.pageTitle).toEqual('Academic records');
    });

    it('sets subjects to the value of Subjects.all()', function() {
      expect(Subjects.all).toHaveBeenCalled();
      expect(scope.subjects).toEqual([{id: 1, name: 'One'}, {id: 3, name: 'Three'}]);
    });

    describe('add()', function() {
      beforeEach(function() {
        Subjects.add = jasmine.createSpy('Subjects.add').andReturn('subject');
        scope.add('test');
      });

      it('adds alls Subjects.add()', function() {
        expect(Subjects.add).toHaveBeenCalled();
      });

      it('sets _edit to name for the new object', function() {
        expect(Subjects.add.mostRecentCall.args[0]).toEqual({ _edit: 'name' });
      });
    });

    describe('delete(subject)', function () {
      var subject;

      beforeEach(function() {
        subject = { delete: jasmine.createSpy() };
      });

      describe('on confirm', function () {
        beforeEach(function () {
          scope.delete(subject)
        });

        it('sends a delete message to the subject', function () {
          expect(subject.delete).toHaveBeenCalled();
        });
      });

      describe('on cancel', function () {
        beforeEach(function () {
          confirm.set(false);
          scope.delete(subject)
        });

        it('does not send a delete message to the subject', function () {
          expect(subject.delete).not.toHaveBeenCalled();
        });
      });
    });
  });
});