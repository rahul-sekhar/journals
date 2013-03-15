'use strict';

describe('people module', function() {
  beforeEach(module('journals.people'));

  /*------------------- Students collection -----------------------*/

  describe('Students', function() {
    var collection, model, Students, editableFieldsExtension, association;

    beforeEach(module(function($provide) {
      model = jasmine.createSpy().andReturn('model');
      collection = jasmine.createSpy().andReturn('collection');
      editableFieldsExtension = jasmine.createSpy().andReturn('editableFieldsExtension');
      association = jasmine.createSpy().andCallFake(function(arg1, name) {
        return name + ' association';
      });
      $provide.value('model', model);
      $provide.value('collection', collection);
      $provide.value('editableFieldsExtension', editableFieldsExtension);
      $provide.value('association', association);
    }));

    beforeEach(inject(function(_Students_) {
      Students = _Students_;
    }));

    it('sets the model name to "student"', function() {
      expect(model.mostRecentCall.args[0]).toEqual('student');
    });

    it('sets the model url to "/students"', function() {
      expect(model.mostRecentCall.args[1]).toEqual('/students');
    });

    it('sets the extensions', function() {
      expect(model.mostRecentCall.args[2].extensions).toEqual(
        ['guardian association', 'group association', 'mentor association', 'editableFieldsExtension']
      );
    });

    it('calls the collection with the model object', function() {
      expect(collection).toHaveBeenCalledWith('model', { url: '/students/all' });
    });

    it('returns the collection object', function() {
      expect(Students).toEqual('collection');
    });
  });



  /*------------------- Teachers collection -----------------------*/

  describe('Teachers', function() {
    var collection, model, Teachers, editableFieldsExtension, association;

    beforeEach(module(function($provide) {
      model = jasmine.createSpy().andReturn('model');
      collection = jasmine.createSpy().andReturn('collection');
      editableFieldsExtension = jasmine.createSpy().andReturn('editableFieldsExtension');
      association = jasmine.createSpy().andCallFake(function(arg1, name) {
        return name + ' association';
      });
      $provide.value('model', model);
      $provide.value('collection', collection);
      $provide.value('editableFieldsExtension', editableFieldsExtension);
      $provide.value('association', association);
    }));

    beforeEach(inject(function(_Teachers_) {
      Teachers = _Teachers_;
    }));

    it('sets the model name to "teacher"', function() {
      expect(model.mostRecentCall.args[0]).toEqual('teacher');
    });

    it('sets the model url to "/teachers"', function() {
      expect(model.mostRecentCall.args[1]).toEqual('/teachers');
    });

    it('sets the extensions', function() {
      expect(model.mostRecentCall.args[2].extensions).toEqual(
        ['mentee association', 'editableFieldsExtension']
      );
    });

    it('calls the collection with the model object', function() {
      expect(collection).toHaveBeenCalledWith('model', { url: '/teachers/all' });
    });

    it('returns the collection object', function() {
      expect(Teachers).toEqual('collection');
    });
  });
  

  /*------------------- Guardians collection -----------------------*/

  describe('Guardians', function() {
    var collection, model, Guardians, editableFieldsExtension;

    beforeEach(module(function($provide) {
      model = jasmine.createSpy().andReturn('model');
      collection = jasmine.createSpy().andReturn('collection');
      editableFieldsExtension = jasmine.createSpy().andReturn('editableFieldsExtension');
      $provide.value('model', model);
      $provide.value('collection', collection);
      $provide.value('editableFieldsExtension', editableFieldsExtension);
    }));

    beforeEach(inject(function(_Guardians_) {
      Guardians = _Guardians_;
    }));

    it('sets the model name to "guardian"', function() {
      expect(model.mostRecentCall.args[0]).toEqual('guardian');
    });

    it('sets the model url to "/guardians"', function() {
      expect(model.mostRecentCall.args[1]).toEqual('/guardians');
    });

    it('sets the extensions', function() {
      expect(model.mostRecentCall.args[2].extensions).toEqual(['editableFieldsExtension']);
    });

    it('calls the collection with the model object', function() {
      expect(collection).toHaveBeenCalledWith('model');
    });

    it('returns the collection object', function() {
      expect(Guardians).toEqual('collection');
    });
  });



  /*------------------- People interface ------------------------*/

  describe('peopleInterface', function() {
    var peopleInterface, httpBackend, promise, success, error, Teachers, Students;

    beforeEach(inject(function(_peopleInterface_, $httpBackend, _Teachers_, _Students_) {
      peopleInterface = _peopleInterface_
      httpBackend = $httpBackend;
      success = jasmine.createSpy();
      error = jasmine.createSpy();
      Teachers = _Teachers_;
      Students = _Students_;
      spyOn(Teachers, 'update').andReturn('teacher');
      spyOn(Students, 'update').andReturn('student');
    }));


    // Load collection

    describe('load()', function() {
      describe('for an invalid type', function() {
        beforeEach(function() {
          httpBackend.expectGET('/path').respond({
            items: [{id: 1, type: 'Something', name: "One"}, {id: 2, type: 'Teacher', name: "Two"}]
          });
          peopleInterface.load('/path');
        });
        
        it('throws an error', function() {
          expect(httpBackend.flush).toThrow('Invalid type for person');
        });
      });

      describe('on success', function() {
        beforeEach(function() {
          httpBackend.expectGET('/path').respond({
            data: 'value',
            other_data: 'other_value',
            items: [{id: 1, type: 'Student', name: "One"}, {id: 2, type: 'Teacher', name: "Two"}, {id: 3, type: 'Student'}]
          });
          promise = peopleInterface.load('/path');
          promise.then(success, error);
        });

        it('sends a request to the server', function() {
          httpBackend.verifyNoOutstandingExpectation();
        });

        it('does not immediately resolve the promise', function() {
          expect(success).not.toHaveBeenCalled();
          expect(error).not.toHaveBeenCalled();
        });

        describe('on response', function() {
          beforeEach(function() {
            httpBackend.flush();
          });

          it('resolves the promise', function() {
            expect(success).toHaveBeenCalled();
          });

          it('updates Teachers with each teacher', function() {
            expect(Teachers.update).toHaveBeenCalledWith({id: 2, type: 'Teacher', name: "Two"});
          });

          it('updates Students with each student', function() {
            expect(Students.update.callCount).toEqual(2);
            expect(Students.update.argsForCall[0]).toEqual([{id: 1, type: 'Student', name: "One"}]);
            expect(Students.update.argsForCall[1]).toEqual([{id: 3, type: 'Student'}]);
          });

          describe('the resolved data', function() {
            var response;

            beforeEach(function() {
              response = success.mostRecentCall.args[0];
            });

            it('contains the response metadata', function() {
              expect(response.metadata).toEqual({ data: 'value', other_data: 'other_value' });
            });

            it('contains the student and teacher instances', function() {
              expect(response.people).toEqual(['student', 'teacher', 'student']);
            });
          });
        });
      });

      describe('on failure', function() {
        beforeEach(function() {
          httpBackend.expectGET('/path').respond(400);
          promise = peopleInterface.load('/path');
          promise.then(success, error);
        });

        it('rejects the promise', function() {
          httpBackend.flush();
          expect(success).not.toHaveBeenCalled();
          expect(error).toHaveBeenCalled();
        });
      });
    });

  
    // Load profile

    describe('loadProfile()', function() {
      describe('for an invalid type', function() {
        beforeEach(function() {
          httpBackend.expectGET('/path').respond({ id: 1, type: 'Something', name: "One"});
          peopleInterface.loadProfile('/path');
        });
        
        it('throws an error', function() {
          expect(httpBackend.flush).toThrow('Invalid type for person');
        });
      });
      
      describe('on success', function() {
        describe('for a student', function() {
          beforeEach(function() {
            httpBackend.expectGET('/path').respond({id: 5, type: 'Student', full_name: 'Something', field: 'val'});
            promise = peopleInterface.loadProfile('/path');
            promise.then(success, error);
          });

          it('sends a request to the server', function() {
            httpBackend.verifyNoOutstandingExpectation();
          });

          it('does not immediately resolve the promise', function() {
            expect(success).not.toHaveBeenCalled();
            expect(error).not.toHaveBeenCalled();
          });

          describe('on response', function() {
            beforeEach(function() {
              httpBackend.flush();
            });

            it('resolves the promise', function() {
              expect(success).toHaveBeenCalled();
            });

            it('updates Students with the student', function() {
              expect(Students.update).toHaveBeenCalledWith({id: 5, type: 'Student', full_name: 'Something', field: 'val'});
            });

            describe('the resolved data', function() {
              var response;

              beforeEach(function() {
                response = success.mostRecentCall.args[0];
              });

              it('contains the student name', function() {
                expect(response.name).toEqual('Something');
              });

              it('contains the student instance', function() {
                expect(response.people).toEqual(['student']);
              });
            });
          });
        });

        describe('for a teacher', function() {
          beforeEach(function() {
            httpBackend.expectGET('/path').respond({id: 5, type: 'Teacher', full_name: 'Something', field: 'val'});
            promise = peopleInterface.loadProfile('/path');
            promise.then(success, error);
            httpBackend.flush();
          });

          it('updates Teachers with the teacher', function() {
            expect(Teachers.update).toHaveBeenCalledWith({id: 5, type: 'Teacher', full_name: 'Something', field: 'val'});
          });

          describe('the resolved data', function() {
            var response;

            beforeEach(function() {
              response = success.mostRecentCall.args[0];
            });

            it('contains the teacher name', function() {
              expect(response.name).toEqual('Something');
            });

            it('contains the teacher instance', function() {
              expect(response.people).toEqual(['teacher']);
            });
          });
        });

        describe('for a guardian', function() {
          beforeEach(function() {
            httpBackend.expectGET('/path').respond({
              id: 5, 
              type: 'Guardian', 
              full_name: 'Something', 
              field: 'val',
              students: [
                {id: 3, full_name: 'Three', type: 'Student'},
                {id: 1, full_name: 'One', type: 'Student'}
              ]
            });
            promise = peopleInterface.loadProfile('/path');
            promise.then(success, error);
            httpBackend.flush();
          });

          it('updates Students with each student', function() {
            expect(Students.update.callCount).toEqual(2);
            expect(Students.update.argsForCall[0][0]).toEqual({id: 3, full_name: 'Three', type: 'Student'});
            expect(Students.update.argsForCall[1][0]).toEqual({id: 1, full_name: 'One', type: 'Student'});
          });

          describe('the resolved data', function() {
            var response;

            beforeEach(function() {
              response = success.mostRecentCall.args[0];
            });

            it('contains the guardian name', function() {
              expect(response.name).toEqual('Something');
            });

            it('contains the student instances', function() {
              expect(response.people).toEqual(['student', 'student']);
            });
          });
        });
      });

      describe('on failure', function() {
        beforeEach(function() {
          httpBackend.expectGET('/path').respond(400);
          promise = peopleInterface.loadProfile('/path');
          promise.then(success, error);
        });

        it('rejects the promise', function() {
          httpBackend.flush();
          expect(success).not.toHaveBeenCalled();
          expect(error).toHaveBeenCalled();
        });
      });
    });
  });
  
  /*--------------- Profile fields controller --------------*/
  describe('profileFieldsCtrl', function() {
    var scope;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      $controller('profileFieldsCtrl', { $scope: scope });
    }));

    it('sets fields to blank initially', function() {
      expect(scope.fields).toEqual([]);
    });

    it('sets a students fields', function() {
      scope.person = { type: 'Student' };
      scope.$apply();
      var field_names = scope.fields.map(function(obj) {
        return obj.slug;
      });
      expect(field_names).toEqual([
        "formatted_birthday",
        "blood_group",
        "mobile",
        "home_phone",
        "office_phone",
        "email",
        "additional_emails",
        "address",
        "notes"
      ]);
    });

    it('sets a teachers fields', function() {
      scope.person = { type: 'Teacher' };
      scope.$apply();
      var field_names = scope.fields.map(function(obj) {
        return obj.slug;
      });
      expect(field_names).toEqual([
        "mobile",
        "home_phone",
        "office_phone",
        "email",
        "additional_emails",
        "address",
        "notes"
      ]);
    });

    it('sets a guardians fields', function() {
      scope.person = { type: 'Guardian' };
      scope.$apply();
      var field_names = scope.fields.map(function(obj) {
        return obj.slug;
      });
      expect(field_names).toEqual([
        "mobile",
        "home_phone",
        "office_phone",
        "email",
        "additional_emails",
        "address",
        "notes"
      ]);
    });

    describe('hasRemainingFields()', function() {
      var person;

      beforeEach(function() {
        person = scope.person = { type: 'Student' };
        scope.$apply();
      });

      it('returns true if some fields are not set', function() {
        person.home_phone = 'blah blah';
        person.address='something';
        person.blood_group = 'A+';

        scope.$apply();

        expect(scope.hasRemainingFields()).toEqual(true);
      });

      it('returns false if all fields are set', function() {
        person.type = 'Student'
        person.home_phone = 'blah blah';
        person.address='something';
        person.email = 'a@b.c';
        person.mobile = '1234';
        person.formatted_birthday = '11/12/1990';
        person.office_phone = '2345';
        person.blood_group = 'A+';
        person.additional_emails = 'asdf';
        person.notes = 'bcd';

        scope.$apply();

        expect(scope.hasRemainingFields()).toEqual(false);
      });
    });

    describe('addField(field_name)', function() {
      beforeEach(function() {
        scope.person = { editing: {}};
        scope.addField('some_field');
      });

      it('sets editing to true for that field', function() {
        expect(scope.person.editing['some_field']).toEqual(true);
      });
    });
  });


  /*---------------- Date with age filter ---------------*/

  describe('dateWithAge', function() {
    var currentDateMock

    beforeEach(function() {
      module(function($provide) {
        currentDateMock = {
          get: function() {
            return new Date('2013-01-01')
          }
        };
        $provide.value('currentDate', currentDateMock)
      });
    });

    it('converts a date to an age', inject(function(dateWithAgeFilter) {
      expect(dateWithAgeFilter('24-04-2007')).toEqual('24-04-2007 (5 yrs)');
    }));

    it('returns null for a null date', inject(function(dateWithAgeFilter) {
      expect(dateWithAgeFilter(null)).toEqual(null);
    }));

    it('returns null for a blank date', inject(function(dateWithAgeFilter) {
      expect(dateWithAgeFilter('')).toEqual(null);
    }));
  });
});