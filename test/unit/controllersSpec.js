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
      it("includes the common people controller, passing the scope", inject(function($controller) {
        ctrl = $controller(PeopleCtrl, {$scope: scope, commonPeopleCtrl: commonPeopleCtrl});
        expect(commonPeopleCtrl.include).toHaveBeenCalledWith(scope);
      }));
    });

    describe('ArchivedPeopleCtrl', function() {
      it("includes the common people controller, passing the scope and type", inject(function($controller) {
        ctrl = $controller(ArchivedPeopleCtrl, {$scope: scope, commonPeopleCtrl: commonPeopleCtrl});
        expect(commonPeopleCtrl.include).toHaveBeenCalledWith(scope, 'archived');
      }));
    });

    describe('TeachersCtrl', function() {
      it("includes the common people controller, passing the scope, type and id", inject(function($controller) {
        ctrl = $controller(TeachersCtrl, {
          $scope: scope, 
          commonPeopleCtrl: commonPeopleCtrl, 
          $routeParams: { id: 11 }
        });
        expect(commonPeopleCtrl.include).toHaveBeenCalledWith(scope, 'teachers', 11);
      }));
    });

    describe('StudentsCtrl', function() {
      it("includes the common people controller, passing the scope, type and id", inject(function($controller) {
        ctrl = $controller(StudentsCtrl, {
          $scope: scope, 
          commonPeopleCtrl: commonPeopleCtrl, 
          $routeParams: { id: 5 }
        });
        expect(commonPeopleCtrl.include).toHaveBeenCalledWith(scope, 'students', 5);
      }));
    });

    describe('GuardiansCtrl', function() {
      it("includes the common people controller, passing the scope, type and id", inject(function($controller) {
        ctrl = $controller(GuardiansCtrl, {
          $scope: scope, 
          commonPeopleCtrl: commonPeopleCtrl, 
          $routeParams: { id: 5 }
        });
        expect(commonPeopleCtrl.include).toHaveBeenCalledWith(scope, 'guardians', 5);
      }));
    });

  });



  describe('InPlaceEditCtrl', function() {
    var scope, ctrl, parentItem, errorHandlerMock, $httpBackend;
    
    beforeEach(function() {
      module(function($provide) {
        errorHandlerMock = { message: jasmine.createSpy() };
        $provide.value('errorHandler', errorHandlerMock)
      });
    });

    beforeEach(inject(function($rootScope, $controller, _$httpBackend_) {
      $httpBackend = _$httpBackend_;

      parentItem = { id: "13", type: "students", some_field: "some value" };
      scope = $rootScope.$new();
      scope.parent = parentItem;
      scope.fieldName = "some_field";
      
      ctrl = $controller(InPlaceEditCtrl, {$scope: scope});
    }));

    it('sets editMode to false initially', function() {
      expect(scope.editMode).toEqual(false);
    });

    describe('startEdit()', function() {
      it('sets editMode to true', function() {
        scope.startEdit();
        expect(scope.editMode).toEqual(true);
      });

      it('sets editorValue to the parent field value', function() {
        expect(scope.editorValue).toBeUndefined();
        scope.startEdit();
        expect(scope.editorValue).toEqual("some value");
      });
    });

    describe('finishEdit()', function() {
      beforeEach(function() {
        scope.editorValue = "changed value";
      });

      describe('with a valid server response', function() {
        beforeEach(function() {
          var changedParent = { id: "13", type: "students", some_field: "some changed value", random: "random val" }
          $httpBackend.expectPUT('/students/13', { student: { some_field: "changed value" }}).respond(200, changedParent);
        });

        it('sets editMode to false', function() {
          scope.editMode = true;
          scope.finishEdit();
          expect(scope.editMode).toEqual(false);
        });

        it('sets the parent field value to the editorValue', function() {
          expect(parentItem.some_field).toEqual("some value");
          scope.finishEdit();
          expect(parentItem.some_field).toEqual("changed value");
        });

        it('sends the updated field value to the server', function() {
          scope.finishEdit();
          $httpBackend.verifyNoOutstandingExpectation();
        });

        it('does not send anything to the server if the field is unchanged', function() {
          scope.editorValue = "some value"
          $httpBackend.resetExpectations();
          scope.finishEdit();
          $httpBackend.verifyNoOutstandingExpectation();
        });

        it('updates the parent field according to the server response', function() {
          scope.finishEdit();
          expect(parentItem.some_field).toEqual("changed value");
          $httpBackend.flush();
          expect(parentItem.some_field).toEqual("some changed value");
        });
      });

      describe('with an invalid server response', function() {
        beforeEach(function() {
          $httpBackend.expectPUT('/students/13', { student: { some_field: "changed value" }}).respond(422, "Some error");
        });

        it('sets editMode to false', function() {
          scope.editMode = true;
          scope.finishEdit();
          expect(scope.editMode).toEqual(false);
        });

        it('sets the parent field value to the editorValue', function() {
          expect(parentItem.some_field).toEqual("some value");
          scope.finishEdit();
          expect(parentItem.some_field).toEqual("changed value");
        });

        it('resets the parent field value when the server response is received', function() {
          scope.finishEdit();
          expect(parentItem.some_field).toEqual("changed value");
          $httpBackend.flush();
          expect(parentItem.some_field).toEqual("some value");
        });

        it('displays an error message with the server response', function() {
          scope.finishEdit();
          $httpBackend.flush();
          expect(errorHandlerMock.message).toHaveBeenCalledWith("Some error");
        });
      });
    });

    describe('cancelEdit()', function() {
      it('sets editMode to false', function() {
        scope.editMode = true
        scope.cancelEdit();
        expect(scope.editMode).toEqual(false);
      });
    });

    describe('clearEdit()', function() {
      beforeEach(function() {
        scope.finishEdit = jasmine.createSpy();
      });

      it('clears the editor value', function() {
        scope.editorValue = "Some val";
        scope.clearEdit();
        expect(scope.editorValue).toEqual(null);
      });

      it('calls finish edit', function() {
        scope.clearEdit();
        expect(scope.finishEdit).toHaveBeenCalled();
      });
    });
  });
});

