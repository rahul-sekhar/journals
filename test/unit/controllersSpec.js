'use strict';

describe('Controllers', function() {

  beforeEach(module('journalsApp.services'));

  describe('FieldsCtrl', function() {
    var profileFields, scope, person, $controller;

    beforeEach(inject(function(_profileFields_, $rootScope, _$controller_) {
      profileFields = _profileFields_;
      scope = $rootScope.$new();
      $controller = _$controller_;
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
        $provide.value('dialogHandler', dialogHandlerMock);
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
          var changedParent = { id: "13", type: "students", some_field: "some changed value", random: "random val" };
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

      describe('with a parent with no type, using a default type', function() {
        beforeEach(function() {
          scope.type = 'groups';
          parentItem = { id: "13", some_field: "some value" };
          scope.parent = parentItem;
          var changedParent = { id: "13", some_field: "some changed value", random: "random val" };
          $httpBackend.expectPUT('/groups/13', { group: { some_field: "changed value" }}).respond(200, changedParent);
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
        scope.editMode = true;
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

    describe('for a parent with an id', function() {
      beforeEach(inject(function($controller) {
        scope.parent = { id: 7, type: "students", some_field: "" };
        ctrl = $controller(InPlaceEditCtrl, {$scope: scope});
      }));

      it('sets editMode to false', function() {
        scope.$apply();
        expect(scope.editMode).toEqual(false);
      });
    });

    describe('for a parent with no id', function() {
      beforeEach(function() {
        parentItem = { type: "students", some_field: "" };
        scope.parent = parentItem;
      });

      describe('with a blank value for the editors field', function() {
        beforeEach(inject(function($controller) {
          ctrl = $controller(InPlaceEditCtrl, {$scope: scope});
        }));

        it('sets editMode to true', function() {
          scope.$apply();
          expect(scope.editMode).toEqual(true);
        });
      });
      
      describe('with no value for the editors field', function() {
        beforeEach(inject(function($controller) {
          scope.parent = { type: "students", other_field: "" };
          ctrl = $controller(InPlaceEditCtrl, {$scope: scope});
        }));

        it('sets editMode to true', function() {
          scope.$apply();
          expect(scope.editMode).toEqual(false);
        });
      });

      describe('cancelEdit()', function() {
        it('calls the parents destroy function', function() {
          parentItem.destroy = jasmine.createSpy();
          scope.parent = parentItem;
          scope.cancelEdit();
          expect(parentItem.destroy).toHaveBeenCalled();
        });
      });

      describe('finishEdit()', function() {
        it('calls the parents create function', function() {
          parentItem.create = jasmine.createSpy();
          scope.parent = parentItem;
          scope.editorValue = 'some_val'
          scope.finishEdit();
          expect(parentItem.create).toHaveBeenCalledWith({student: {some_field: 'some_val'}});
        });
      });
    });
  });

  
  describe('GroupsCtrl', function() {
    var scope, ctrl, $httpBackend, dialogHandlerMock;

    beforeEach(inject(function($rootScope, $controller, _$httpBackend_) {
      $httpBackend = _$httpBackend_;
      $httpBackend.expectGET('/groups').respond([{name: "Group 1", id: 5}, {name: "Group 2", id: 10}]);
      dialogHandlerMock = { message: jasmine.createSpy() };
      scope = $rootScope.$new();
      ctrl = $controller(GroupsCtrl, { $scope: scope, dialogHandler: dialogHandlerMock });
    }));

    it('retrieves a list of groups', function() {
      expect(scope.groups).toEqualData([]);
      $httpBackend.flush();
      expect(scope.groups).toEqualData([{name: "Group 1", id: 5}, {name: "Group 2", id: 10}]);
    });

    it('sets the default type', function() {
      expect(scope.defaultType).toEqual('groups');
    });

    describe('delete()', function() {
      beforeEach(function() {
        $httpBackend.flush();
        $httpBackend.expectDELETE('/groups/5').respond(200);
        scope.delete(scope.groups[0]);
      });

      it('removes the group from the groups array', function() {
        expect(scope.groups).toEqualData([{name: "Group 2", id: 10}]);
      });

      it('sends a delete request', function() {
        $httpBackend.verifyNoOutstandingExpectation();
      });
    });

    describe('add()', function() {
      beforeEach(function() {
        $httpBackend.flush();
      });

      it('adds a new group with a blank name to the groups array, in the first position', function() {
        scope.add();
        expect(scope.groups).toEqualData([{name: ""},{name: "Group 1", id: 5}, {name: "Group 2", id: 10}])
      });

      describe('the added group', function() {
        var group;
        
        beforeEach(function() {
          scope.add();
          group = scope.groups[0]
        });

        describe('destroy()', function() {
          it('removes the group from the groups array', function() {
            group.destroy();
            expect(scope.groups).toEqualData([{name: "Group 1", id: 5}, {name: "Group 2", id: 10}])
          });
        });

        describe('create()', function() {
          describe('on success', function() {
            beforeEach(function() {
              $httpBackend.expectPOST('/groups', {group: {name: 'blah'}}).respond({name: 'blah', id: 56});
              group.create({group: {name: 'blah'}});
            });

            it('posts the data to the server', function() {
              $httpBackend.verifyNoOutstandingExpectation();
            });

            it('updates the group in the array', function() {
              $httpBackend.flush();
              expect(scope.groups).toEqualData([{name: 'blah', id: 56}, {name: "Group 1", id: 5}, {name: "Group 2", id: 10}])
            });
          });
          
          describe('on failure', function() {
            beforeEach(function() {
              $httpBackend.expectPOST('/groups', {group: {name: 'blah'}}).respond(422, 'error!');
              group.create({group: {name: 'blah'}});
            });

            it('removes the group from the array', function() {
              $httpBackend.flush();
              expect(scope.groups).toEqualData([{name: "Group 1", id: 5}, {name: "Group 2", id: 10}])
            });

            it('displays an error message', function() {
              $httpBackend.flush();
              expect(dialogHandlerMock.message).toHaveBeenCalledWith('error!');
            });            
          });
        });
      });
    });
  });
});

