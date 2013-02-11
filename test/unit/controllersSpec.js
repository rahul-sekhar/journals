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

  describe('People controllers', function() {

    var scope, ctrl, commonPeopleCtrl;

    beforeEach(inject(function($rootScope) {
      commonPeopleCtrl = { include: jasmine.createSpy() };
      scope = $rootScope.$new();
    }));

    describe('PeopleCtrl', function() {
      it("includes the common people controller, passing the scope", inject(function($rootScope, $controller) {
        ctrl = $controller(PeopleCtrl, {$scope: scope, commonPeopleCtrl: commonPeopleCtrl});
        expect(commonPeopleCtrl.include).toHaveBeenCalledWith(scope);
      }));
    });

    describe('ArchivedPeopleCtrl', function() {
      it("includes the common people controller, passing the scope and type", inject(function($rootScope, $controller) {
        ctrl = $controller(ArchivedPeopleCtrl, {$scope: scope, commonPeopleCtrl: commonPeopleCtrl});
        expect(commonPeopleCtrl.include).toHaveBeenCalledWith(scope, 'archived');
      }));
    });

    describe('TeachersCtrl', function() {
      it("includes the common people controller, passing the scope, type and id", inject(function($rootScope, $controller) {
        ctrl = $controller(TeachersCtrl, {
          $scope: scope, 
          commonPeopleCtrl: commonPeopleCtrl, 
          $routeParams: { id: 11 }
        });
        expect(commonPeopleCtrl.include).toHaveBeenCalledWith(scope, 'teachers', 11);
      }));
    });

    describe('StudentsCtrl', function() {
      it("includes the common people controller, passing the scope, type and id", inject(function($rootScope, $controller) {
        ctrl = $controller(StudentsCtrl, {
          $scope: scope, 
          commonPeopleCtrl: commonPeopleCtrl, 
          $routeParams: { id: 5 }
        });
        expect(commonPeopleCtrl.include).toHaveBeenCalledWith(scope, 'students', 5);
      }));
    });

    describe('GuardiansCtrl', function() {
      it("includes the common people controller, passing the scope, type and id", inject(function($rootScope, $controller) {
        ctrl = $controller(GuardiansCtrl, {
          $scope: scope, 
          commonPeopleCtrl: commonPeopleCtrl, 
          $routeParams: { id: 5 }
        });
        expect(commonPeopleCtrl.include).toHaveBeenCalledWith(scope, 'guardians', 5);
      }));
    });

  });
});

