'use strict';

describe('Controllers', function() {
  
  beforeEach(function() {
    this.addMatchers({
      toEqualData: function(expected) {
        return angular.equals(this.actual, expected);
      }
    });
  });

  beforeEach(module('journalsApp.services'));

  describe('PeopleCtrl', function() {
    var scope, ctrl, $httpBackend;

    beforeEach(inject(function(_$httpBackend_, $rootScope, $controller) {
      $httpBackend = _$httpBackend_;
      $httpBackend.expectGET('/people').respond([
        { id: 12, type: 'student', name: 'Student 1'},
        { id: 15, type: 'teacher', name: 'Teacher 1'}
      ]);

      scope = $rootScope.$new();
      ctrl = $controller(PeopleCtrl, {$scope: scope});
    }));

    it('set people to the list fetched via xhr', inject(function(Person) {
      expect(scope.phones).toBeUndefined();
      $httpBackend.flush();
      expect(scope.people).toEqualData([
        { id: 12, type: 'student', name: 'Student 1'},
        { id: 15, type: 'teacher', name: 'Teacher 1'}
      ]);
    }));
  });
});

