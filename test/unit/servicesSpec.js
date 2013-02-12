'use strict';

describe('service', function() {
  
  beforeEach(function() {
    this.addMatchers({
      toEqualData: function(expected) {
        return angular.equals(this.actual, expected);
      }
    });
  });

  beforeEach(module('journalsApp.services'));


  describe('Person', function() {
    var result, $httpBackend;

    beforeEach(inject(function(_$httpBackend_) {
      $httpBackend = _$httpBackend_;
    }));

    it('should query people', inject(function(Person) {
      $httpBackend.expectGET('/people').respond([{full_name: 'Student 1'}]);
      result = Person.query();
      $httpBackend.flush();
      expect(result).toEqualData([{full_name: 'Student 1'}]);
    }));

    it('should query archived people', inject(function(Person) {
      $httpBackend.expectGET('/people/archived').respond([{full_name: 'Student 1'}]);
      result = Person.query_archived();
      $httpBackend.flush();
      expect(result).toEqualData([{full_name: 'Student 1'}]);
    }));

    it("should get a teacher", inject(function(Person) {
      $httpBackend.expectGET('/teachers/5').respond({full_name: 'Teacher Name'})
      result = Person.get({type: 'teachers', id: 5});
      $httpBackend.flush();
      expect(result).toEqualData({full_name:"Teacher Name"});
    }));

    it("should get a student", inject(function(Person) {
      $httpBackend.expectGET('/students/5').respond({full_name: 'Student Name'})
      result = Person.get({type: 'students', id: 5});
      $httpBackend.flush();
      expect(result).toEqualData({full_name:"Student Name"});
    }));
  });


  describe('commonPeopleCtrl', function() {
    var scope, ctrl, $httpBackend, errorHandlerMock;

    beforeEach(function() {
      module(function($provide) {
        errorHandlerMock = {
          message: jasmine.createSpy(),
          raise_404: jasmine.createSpy()
        };
        $provide.value('errorHandler', errorHandlerMock)
      });

      inject(function(commonPeopleCtrl, _$httpBackend_, $rootScope) {
        ctrl = commonPeopleCtrl;
        $httpBackend = _$httpBackend_;
        scope = $rootScope.$new();
      })
    });


    describe('Array of people', function() {

      describe('All people', function() {     
        beforeEach(function() {
          $httpBackend.expectGET('/people').respond([
            { id: 12, type: 'students', full_name: 'Student 1'},
            { id: 15, type: 'teachers', full_name: 'Teacher 1'}
          ]);
          ctrl.include(scope);
        });

        it('sets people to the list fetched via xhr', inject(function(Person) {
          expect(scope.people).toEqual([]);
          $httpBackend.flush();
          expect(scope.people).toEqualData([
            { id: 12, type: 'students', full_name: 'Student 1'},
            { id: 15, type: 'teachers', full_name: 'Teacher 1'}
          ]);
        }));
      });


      describe('Archived people', function() {     
        beforeEach(function() {
          $httpBackend.expectGET('/people/archived').respond([
            { id: 12, type: 'students', full_name: 'Student 1'},
            { id: 15, type: 'teachers', full_name: 'Teacher 1'}
          ]);
          ctrl.include(scope, 'archived');
        });

        it('sets people to the list fetched via xhr', inject(function(Person) {
          expect(scope.people).toEqual([]);
          $httpBackend.flush();
          expect(scope.people).toEqualData([
            { id: 12, type: 'students', full_name: 'Student 1'},
            { id: 15, type: 'teachers', full_name: 'Teacher 1'}
          ]);
        }));
      });


      describe('Single teacher', function() {
        beforeEach(function() {
          $httpBackend.expectGET('/teachers/17').respond(
            { id: 17, type: 'teachers', full_name: 'Some Teacher'}
          );
          ctrl.include(scope, 'teachers', 17)
        });

        it('sets people to the list fetched via xhr', function() {
          expect(scope.people).toEqualData([]);
          $httpBackend.flush();
          expect(scope.people).toEqualData([
            { id: 17, type: 'teachers', full_name: 'Some Teacher'}
          ]);
        });
      });

      describe('Non-existent teacher', function() {
        beforeEach(function() {
          $httpBackend.expectGET('/teachers/17').respond(function() {
            return [404, {}];
          });
          ctrl.include(scope, 'teachers', 17)
        });

        it('set reports an error message and sets people to an empty array', function() {
          expect(scope.people).toEqualData([]);
          expect(errorHandlerMock.message).not.toHaveBeenCalled();
          $httpBackend.flush();
          expect(errorHandlerMock.message).toHaveBeenCalled();
          expect(scope.people).toEqualData([]);
        });
      });

      describe('Teachers', function() {
        beforeEach(function() {
          $httpBackend.expectGET('/teachers').respond([
            { id: 17, type: 'teachers', full_name: 'Some Teacher'},
            { id: 20, type: 'teachers', full_name: 'Some Other Teacher'}
          ]);
          ctrl.include(scope, 'teachers', null)
        });

        it('sets people to the list fetched via xhr', function() {
          expect(scope.people).toEqualData([]);
          $httpBackend.flush();
          expect(scope.people).toEqualData([
            { id: 17, type: 'teachers', full_name: 'Some Teacher'},
            { id: 20, type: 'teachers', full_name: 'Some Other Teacher'}
          ]);
        });
      });


      describe('Single student', function() {
        beforeEach(function() {
          $httpBackend.expectGET('/students/17').respond(
            { id: 17, type: 'students', full_name: 'Some Student'}
          );
          ctrl.include(scope, 'students', 17)
        });

        it('sets people to the list fetched via xhr', function() {
          expect(scope.people).toEqualData([]);
          $httpBackend.flush();
          expect(scope.people).toEqualData([
            { id: 17, type: 'students', full_name: 'Some Student'}
          ]);
        });
      });

      describe('Non-existent student', function() {
        beforeEach(function() {
          $httpBackend.expectGET('/students/17').respond(function() {
            return [404, {}];
          });
          ctrl.include(scope, 'students', 17)
        });

        it('set reports an error message and sets people to an empty array', function() {
          expect(scope.people).toEqualData([]);
          expect(errorHandlerMock.message).not.toHaveBeenCalled();
          $httpBackend.flush();
          expect(errorHandlerMock.message).toHaveBeenCalled();
          expect(scope.people).toEqualData([]);
        });
      });

      describe('Students', function() {
        beforeEach(function() {
          $httpBackend.expectGET('/students').respond([
            { id: 17, type: 'students', full_name: 'Some Student'},
            { id: 20, type: 'students', full_name: 'Some Other Student'}
          ]);
          ctrl.include(scope, 'students', null)
        });

        it('sets people to the list fetched via xhr', function() {
          expect(scope.people).toEqualData([]);
          $httpBackend.flush();
          expect(scope.people).toEqualData([
            { id: 17, type: 'students', full_name: 'Some Student'},
            { id: 20, type: 'students', full_name: 'Some Other Student'}
          ]);
        });
      });



      describe('Single guardian', function() {
        beforeEach(function() {
          $httpBackend.expectGET('/guardians/17').respond({
            id: 12,
            type: 'guardians',
            students: [
              { id: 13, type: 'students', full_name: 'Some Student'},
              { id: 14, type: 'students', full_name: 'Some Other Student'}
            ]
          });
          ctrl.include(scope, 'guardians', 17)
        });

        it('sets people to the list fetched via xhr', function() {
          expect(scope.people).toEqualData([]);
          $httpBackend.flush();
          expect(scope.people).toEqualData([
            { id: 13, type: 'students', full_name: 'Some Student'},
            { id: 14, type: 'students', full_name: 'Some Other Student'}
          ]);
        });
      });

      describe('Non-existent guardian', function() {
        beforeEach(function() {
          $httpBackend.expectGET('/guardians/17').respond(function() {
            return [404, {}];
          });
          ctrl.include(scope, 'guardians', 17)
        });

        it('set reports an error message and sets people to an empty array', function() {
          expect(scope.people).toEqualData([]);
          expect(errorHandlerMock.message).not.toHaveBeenCalled();
          $httpBackend.flush();
          expect(errorHandlerMock.message).toHaveBeenCalled();
          expect(scope.people).toEqualData([]);
        });
      });

      describe('Guardians', function() {
        beforeEach(function() {
          ctrl.include(scope, 'guardians')
        });

        it('set reports an error message and sets people to an empty array', function() {
          expect(errorHandlerMock.raise_404).toHaveBeenCalled();
          expect(scope.people).toEqualData([]);
        });
      });

    });

    
    
    describe("fieldList", function() {
      beforeEach(function() {
        $httpBackend.expectGET('/people').respond([]);
        ctrl.include(scope);
      });

      it("lists a students fields when passed a student", function() {
        expect(scope.fieldList({type: 'students'})).toEqual([
          "blood_group",
          "mobile",
          "home_phone",
          "office_phone",
          "email",
          "additional_emails",
        ]);
      });

      it("lists a teachers fields when passed a teacher", function() {
        expect(scope.fieldList({type: 'teachers'})).toEqual([
          "mobile",
          "home_phone",
          "office_phone",
          "email",
          "additional_emails",
        ]);
      });

      it("lists a guardians fields when passed a guardian", function() {
        expect(scope.fieldList({type: 'guardians'})).toEqual([
          "mobile",
          "home_phone",
          "office_phone",
          "email",
          "additional_emails",
        ]);
      });
    });


    describe("dateFieldList", function() {
      beforeEach(function() {
        $httpBackend.expectGET('/people').respond([]);
        ctrl.include(scope);
      });

      it("lists a students fields when passed a student", function() {
        expect(scope.dateFieldList({type: 'students'})).toEqual(["birthday"]);
      });

      it("lists an empty array when passed a teacher", function() {
        expect(scope.dateFieldList({type: 'teachers'})).toEqual([]);
      });

      it("lists an empty array when passed a guardian", function() {
        expect(scope.dateFieldList({type: 'guardians'})).toEqual([]);
      });
    });

    describe("multiLineFieldList", function() {
      beforeEach(function() {
        $httpBackend.expectGET('/people').respond([]);
        ctrl.include(scope);
      });

      it("lists a students fields when passed a student", function() {
        expect(scope.multiLineFieldList({type: 'students'})).toEqual(["address", "notes"]);
      });

      it("lists a teachers fields when passed a teacher", function() {
        expect(scope.multiLineFieldList({type: 'teachers'})).toEqual(["address", "notes"]);
      });

      it("lists a guardians fields when passed a guardian", function() {
        expect(scope.multiLineFieldList({type: 'guardians'})).toEqual(["address", "notes"]);
      });
    });
  });
});
