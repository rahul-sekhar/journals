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
      $httpBackend.expectGET('/people').respond([{name: 'Student 1'}]);
      result = Person.query();
      $httpBackend.flush();
      expect(result).toEqualData([{name: 'Student 1'}]);
    }));

    it("should get a teacher", inject(function(Person) {
      $httpBackend.expectGET('/teachers/5').respond({name: 'Teacher Name'})
      result = Person.get({type: 'teachers', id: 5});
      $httpBackend.flush();
      expect(result).toEqualData({name:"Teacher Name"});
    }));

    it("should get a student", inject(function(Person) {
      $httpBackend.expectGET('/students/5').respond({name: 'Student Name'})
      result = Person.get({type: 'students', id: 5});
      $httpBackend.flush();
      expect(result).toEqualData({name:"Student Name"});
    }));
  });


  describe('commonPeopleCtrl', function() {
    var scope, ctrl, $httpBackend, errorHandlerMock;

    beforeEach(function() {
      module(function($provide) {
        errorHandlerMock = {message: jasmine.createSpy()};
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
            { id: 12, type: 'students', name: 'Student 1'},
            { id: 15, type: 'teachers', name: 'Teacher 1'}
          ]);
          ctrl.include(scope);
        });

        it('sets people to the list fetched via xhr', inject(function(Person) {
          expect(scope.people).toEqual([]);
          $httpBackend.flush();
          expect(scope.people).toEqualData([
            { id: 12, type: 'students', name: 'Student 1'},
            { id: 15, type: 'teachers', name: 'Teacher 1'}
          ]);
        }));
      });


      describe('Single teacher', function() {
        beforeEach(function() {
          $httpBackend.expectGET('/teachers/17').respond(
            { id: 17, type: 'teachers', name: 'Some Teacher'}
          );
          ctrl.include(scope, 'teachers', 17)
        });

        it('sets people to the list fetched via xhr', function() {
          expect(scope.people).toEqualData([]);
          $httpBackend.flush();
          expect(scope.people).toEqualData([
            { id: 17, type: 'teachers', name: 'Some Teacher'}
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


      describe('Single student', function() {
        beforeEach(function() {
          $httpBackend.expectGET('/students/17').respond(
            { id: 17, type: 'students', name: 'Some Student'}
          );
          ctrl.include(scope, 'students', 17)
        });

        it('sets people to the list fetched via xhr', function() {
          expect(scope.people).toEqualData([]);
          $httpBackend.flush();
          expect(scope.people).toEqualData([
            { id: 17, type: 'students', name: 'Some Student'}
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

    });

    
    describe("field_list", function() {
      beforeEach(function() {
        $httpBackend.expectGET('/people').respond([]);
        ctrl.include(scope);
      });

      it("lists a students fields when passed a student", function() {
        expect(scope.field_list({type: 'students'})).toEqual([
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

      it("lists a teachers fields when passed a teacher", function() {
        expect(scope.field_list({type: 'teachers'})).toEqual([
          "mobile",
          "home_phone",
          "office_phone",
          "email",
          "additional_emails",
          "address",
          "notes"
        ]);
      });
    })


    describe("date_field_list", function() {
      beforeEach(function() {
        $httpBackend.expectGET('/people').respond([]);
        ctrl.include(scope);
      });

      it("lists a students fields when passed a student", function() {
        expect(scope.date_field_list({type: 'students'})).toEqual(["birthday"]);
      });

      it("lists a teachers fields when passed a teacher", function() {
        expect(scope.date_field_list({type: 'teachers'})).toEqual([]);
      });
    })
  });
});
