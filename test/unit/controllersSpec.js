'use strict';

describe('Controllers', function() {
  
  beforeEach(function() {
    this.addMatchers({
      toEqualData: function(expected) {
        return angular.equals(this.actual, expected);
      },
      toEqualArrayData: function(expected) {
        return $(this.actual).not(expected).length == 0 && $(expected).not(this.actual).length == 0
      }
    });
  });

  beforeEach(module('journalsApp.services'));

  describe('People controllers', function() {
    var scope, ctrl, Person, PeopleCtrlBase;

    beforeEach(inject(function($rootScope, _Person_) {
      scope = $rootScope.$new();
      Person = _Person_;
      PeopleCtrlBase = { include: jasmine.createSpy() };
    }));

    describe('PeopleCtrl', function() {
      beforeEach(inject(function($controller) {
        ctrl = $controller(PeopleCtrl, {$scope: scope, PeopleCtrlBase: PeopleCtrlBase});
      }));
      
      it('sets the page title', function() {
        expect(scope.pageTitle).toEqual('People')
      });

      it('includes PeopleCtrlBase with the scope and query function', function() {
        expect(PeopleCtrlBase.include).toHaveBeenCalledWith(scope, Person.query);
      });
    });

    describe('ArchivedPeopleCtrl', function() {     
      beforeEach(inject(function($controller) {
        ctrl = $controller(ArchivedPeopleCtrl, {$scope: scope, PeopleCtrlBase: PeopleCtrlBase});
      }));
      
      it('sets the page title', function() {
        expect(scope.pageTitle).toEqual('Archived people')
      });

      it('includes PeopleCtrlBase with the scope and query function', function() {
        expect(PeopleCtrlBase.include).toHaveBeenCalledWith(scope, Person.query_archived);
      });
    });

    describe('TeachersCtrl', function() {
      beforeEach(inject(function($controller) {
        ctrl = $controller(TeachersCtrl, {$scope: scope, PeopleCtrlBase: PeopleCtrlBase});
      }));
      
      it('sets the page title', function() {
        expect(scope.pageTitle).toEqual('Teachers')
      });

      it('includes PeopleCtrlBase with the scope and query function', function() {
        expect(PeopleCtrlBase.include).toHaveBeenCalledWith(scope, Person.query_teachers);
      });
    });

    describe('StudentsCtrl', function() {
      beforeEach(inject(function($controller) {
        ctrl = $controller(StudentsCtrl, {$scope: scope, PeopleCtrlBase: PeopleCtrlBase});
      }));
      
      it('sets the page title', function() {
        expect(scope.pageTitle).toEqual('Students')
      });

      it('includes PeopleCtrlBase with the scope and query function', function() {
        expect(PeopleCtrlBase.include).toHaveBeenCalledWith(scope, Person.query_students);
      });
    });
  });

  describe('Single person controllers', function() {
    var scope, ctrl, $httpBackend;

    beforeEach(inject(function($rootScope, _$httpBackend_) {
      scope = $rootScope.$new();
      $httpBackend = _$httpBackend_;
    }));

    describe('SingleTeacherCtrl', function() {
      describe('existing teacher', function() {
        beforeEach(inject(function($controller) {
          $httpBackend.expectGET('/teachers/17').respond(
            { id: 17, type: 'teachers', full_name: 'Some Teacher'}
          );
          ctrl = $controller(SingleTeacherCtrl, {$scope: scope, $routeParams: {id: 17}});
        }));

        it('sets people to the list fetched via xhr', function() {
          expect(scope.people).toBeUndefined();
          $httpBackend.flush();
          expect(scope.people).toEqualData([
            { id: 17, type: 'teachers', full_name: 'Some Teacher'}
          ]);
        });

        it('sets the page title', function() {
          expect(scope.pageTitle).toEqual('Profile')
          $httpBackend.flush();
          expect(scope.pageTitle).toEqual('Profile: Some Teacher')
        });
      });
      
      describe('non-existent teacher', function() {
        beforeEach(inject(function($controller) {
          $httpBackend.expectGET('/teachers/17').respond(function() {
            return [404, {}];
          });
          ctrl = $controller(SingleTeacherCtrl, {$scope: scope, $routeParams: {id: 17}});
        }));

        it('sets people to an empty array', function() {
          expect(scope.people).toBeUndefined();
          $httpBackend.flush();
          expect(scope.people).toEqualData([]);
        });

        it('sets the page title', function() {
          expect(scope.pageTitle).toEqual('Profile')
          $httpBackend.flush();
          expect(scope.pageTitle).toEqual('Profile: Not found')
        });
      });
    });

    describe('SingleStudentCtrl', function() {
      describe('existing student', function() {
        beforeEach(inject(function($controller) {
          $httpBackend.expectGET('/students/17').respond(
            { id: 17, type: 'students', full_name: 'Some Student'}
          );
          ctrl = $controller(SingleStudentCtrl, {$scope: scope, $routeParams: {id: 17}});
        }));

        it('sets people to the list fetched via xhr', function() {
          expect(scope.people).toBeUndefined();
          $httpBackend.flush();
          expect(scope.people).toEqualData([
            { id: 17, type: 'students', full_name: 'Some Student'}
          ]);
        });

        it('sets the page title', function() {
          expect(scope.pageTitle).toEqual('Profile')
          $httpBackend.flush();
          expect(scope.pageTitle).toEqual('Profile: Some Student')
        });
      });
      
      describe('non-existent student', function() {
        beforeEach(inject(function($controller) {
          $httpBackend.expectGET('/students/17').respond(function() {
            return [404, {}];
          });
          ctrl = $controller(SingleStudentCtrl, {$scope: scope, $routeParams: {id: 17}});
        }));

        it('sets people to an empty array', function() {
          expect(scope.people).toBeUndefined();
          $httpBackend.flush();
          expect(scope.people).toEqualData([]);
        });

        it('sets the page title', function() {
          expect(scope.pageTitle).toEqual('Profile')
          $httpBackend.flush();
          expect(scope.pageTitle).toEqual('Profile: Not found')
        });
      });
    });
    
    describe('SingleGuardianCtrl', function() {
      describe('existing guardian', function() {
        beforeEach(inject(function($controller) {
          $httpBackend.expectGET('/guardians/17').respond({
            id: 12,
            type: 'guardians',
            full_name: 'Some Guardian',
            students: [
              { id: 13, type: 'students', full_name: 'Some Student'},
              { id: 14, type: 'students', full_name: 'Some Other Student'}
            ]
          });
          ctrl = $controller(SingleGuardianCtrl, {$scope: scope, $routeParams: {id: 17}});
        }));

        it('sets people to the list fetched via xhr', function() {
          expect(scope.people).toBeUndefined();
          $httpBackend.flush();
          expect(scope.people).toEqualData([
            { id: 13, type: 'students', full_name: 'Some Student'},
            { id: 14, type: 'students', full_name: 'Some Other Student'}
          ]);
        });

        it('sets the page title', function() {
          expect(scope.pageTitle).toEqual('Profile')
          $httpBackend.flush();
          expect(scope.pageTitle).toEqual('Profile: Some Guardian')
        });
      });

      describe('non-existent guardian', function() {
        beforeEach(inject(function($controller) {
          $httpBackend.expectGET('/guardians/17').respond(function() {
            return [404, {}];
          });
          ctrl = $controller(SingleGuardianCtrl, {$scope: scope, $routeParams: {id: 17}});
        }));

        it('sets people to an empty array', function() {
          expect(scope.people).toBeUndefined();
          $httpBackend.flush();
          expect(scope.people).toEqualData([]);
        });

        it('sets the page title', function() {
          expect(scope.pageTitle).toEqual('Profile')
          $httpBackend.flush();
          expect(scope.pageTitle).toEqual('Profile: Not found')
        });
      });
    });
  });
  

  describe('FieldsCtrl', function() {
    var profileFields, scope, person, $controller;

    beforeEach(inject(function(_profileFields_, $rootScope, _$controller_) {
      profileFields = _profileFields_;
      scope = $rootScope.$new();
      $controller = _$controller_
    }));

    describe('field lists', function() {
      it('are set for a student', function() {
        scope.person = { type: 'students' };
        $controller(FieldsCtrl, {$scope: scope});
        expect(scope.standardFields).toEqual(profileFields.standard['students']);
        expect(scope.dateFields).toEqual(profileFields.date['students']);
        expect(scope.multiLineFields).toEqual(profileFields.multiLine['students']);
      });

      it('are set for a teacher', function() {
        scope.person = { type: 'teachers' };
        $controller(FieldsCtrl, {$scope: scope});
        expect(scope.standardFields).toEqual(profileFields.standard['teachers']);
        expect(scope.dateFields).toEqual(profileFields.date['teachers']);
        expect(scope.multiLineFields).toEqual(profileFields.multiLine['teachers']);
      });

      it('are set for a guardian', function() {
        scope.person = { type: 'guardians' };
        $controller(FieldsCtrl, {$scope: scope});
        expect(scope.standardFields).toEqual(profileFields.standard['guardians']);
        expect(scope.dateFields).toEqual(profileFields.date['guardians']);
        expect(scope.multiLineFields).toEqual(profileFields.multiLine['guardians']);
      });
    });

    describe('remainingFields()', function() {
      it("lists remaining fields for a student", function() {
        scope.person = { type: 'students', notes: 'some notes', address: null, mobile: null, home_phone: '1234', blood_group: 'A+' }
        $controller(FieldsCtrl, {$scope: scope});
        expect(scope.remainingFields()).toEqualArrayData([
          "birthday",
          "mobile",
          "office_phone",
          "email",
          "additional_emails",
          "address"
        ]);
      });

      it("checks for formatted_birthday for a student", function() {
        scope.person = { type: 'students', notes: 'some notes', formatted_birthday: '01-01-2010', mobile: null, home_phone: '1234', blood_group: 'A+' }
        $controller(FieldsCtrl, {$scope: scope});
        expect(scope.remainingFields()).toEqualArrayData([
          "mobile",
          "office_phone",
          "email",
          "additional_emails",
          "address"
        ]);
      });

      it("lists remaining fields for a teacher", function() {
        scope.person = { type: 'teachers', notes: 'some notes', address: 'some address', mobile: 'Something', office_phone: '' }
        $controller(FieldsCtrl, {$scope: scope});
        expect(scope.remainingFields()).toEqualArrayData([
          "home_phone",
          "office_phone",
          "email",
          "additional_emails",
        ]);
      });

      it("lists remaining fields for a guardian", function() {
        scope.person = { type: 'guardians', email: 'a@b.c', mobile: 'Something', office_phone: '' }
        $controller(FieldsCtrl, {$scope: scope});
        expect(scope.remainingFields()).toEqualArrayData([
          "notes",
          "address",
          "home_phone",
          "office_phone",
          "additional_emails",
        ]);
      });
    });

    describe("addField()", function() {
      var child_scope;

      beforeEach(function() {
        scope.person = { type: 'teachers' };
        $controller(FieldsCtrl, {$scope: scope});
        child_scope = scope.$new();
      });

      it('broadcasts an event to child scopes', function() {
        var eventSpy = jasmine.createSpy();
        child_scope.$on("addField", eventSpy);
        scope.addField('asdf');
        expect(eventSpy).toHaveBeenCalled();
      });

      it('broadcasts the arguments to addField', function() {
        var argument;
        child_scope.$on("addField", function(e, arg) {
          argument = arg;
        });
        scope.addField('asdf');
        expect(argument).toEqual('asdf');
      });
    });
  });


  describe('InPlaceEditCtrl', function() {
    var scope, ctrl, parentItem, dialogHandlerMock, $httpBackend;
    
    beforeEach(function() {
      module(function($provide) {
        dialogHandlerMock = { message: jasmine.createSpy() };
        $provide.value('dialogHandler', dialogHandlerMock)
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
          expect(dialogHandlerMock.message).toHaveBeenCalledWith("Some error");
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

    describe('addField event', function() {
      var rootScope;

      beforeEach(inject(function($rootScope) {
        rootScope = $rootScope;
      }));
      
      it('sets editMode to true when the field name is matched', function() {
        rootScope.$broadcast("addField", "some_field");
        expect(scope.editMode).toEqual(true);
      });

      it('does not set editMode to true when the field name is not matched', function() {
        rootScope.$broadcast("addField", "other_field");
        expect(scope.editMode).toEqual(false);
      });
    });
  });
});

