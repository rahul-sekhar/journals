'use strict';

describe('academics module', function () {
  beforeEach(module('journals.academics'));

  /*------------------ Academic filters controller ----------------------*/
  describe('AcademicFiltersCtrl', function () {
    var scope, Students, deferred;

    beforeEach(inject(function ($rootScope, $q) {
      scope = $rootScope.$new();
      $rootScope.user = { type: 'Teacher' };

      deferred = $q.defer();
      Students = {
        all: jasmine.createSpy().andReturn('students'),
        get: jasmine.createSpy().andReturn(deferred.promise)
      };
    }));

    describe('with no student_id', function () {
      beforeEach(inject(function ($controller) {
        $controller('AcademicFiltersCtrl', {
          $scope: scope,
          Students: Students,
        });
      }));

      it('sets selected to an empty object', function () {
        expect(scope.selected).toEqual({});
      });

      it('gets all students', function () {
        scope.$apply();
        expect(Students.all).toHaveBeenCalled();
        expect(scope.students).toEqual('students');
      });

      describe('for a student', function () {
        beforeEach(inject(function ($rootScope) {
          $rootScope.user = {
            type: 'Student',
            id: 5
          }
          scope.setStudent = jasmine.createSpy();
          $rootScope.$apply();
        }));

        it('gets the student from the collection', function () {
          expect(Students.get).toHaveBeenCalledWith(5);
        });

        describe('on getting the student', function () {
          var student;

          beforeEach(function () {
            student = { name: 'current student', id: 3 }
            deferred.resolve(student);
            scope.$apply();
          });

          it('sets the selected student', function () {
            expect(scope.setStudent).toHaveBeenCalledWith(student, true);
          });

          it('sets students to that student only', function () {
            expect(scope.students).toEqual([student])
          });
        });
      });
    });

    describe('with a student_id', function () {
      beforeEach(inject(function ($controller, $location) {
        $location.search({student_id: 2});

        $controller('AcademicFiltersCtrl', {
          $scope: scope,
          Students: Students,
        });
      }));

      it('gets all students', function () {
        scope.$apply();
        expect(Students.all).toHaveBeenCalled();
        expect(scope.students).toEqual('students');
      });

      it('gets the student from the collection', function () {
        expect(Students.get).toHaveBeenCalledWith(2);
      });

      describe('on getting the student from the collection', function () {
        var student;

        beforeEach(inject(function ($httpBackend) {
          $httpBackend.expectGET('/students/2/subjects.json').respond(
            [{id: 1, name: 'One'}, {id: 2, name: 'Two'}, {id: 3, name: 'Three'}]
          );

          student = { name: 'some student', id: 2 };
          deferred.resolve(student);
          scope.$apply();
        }));

        it('sets the selected student', function () {
          expect(scope.selected).toEqual({ student: student });
        });

        it('sends a request for subjects', inject(function ($httpBackend) {
          $httpBackend.verifyNoOutstandingExpectation();
        }));

        describe('on response from the server', function () {
          beforeEach(inject(function ($httpBackend) {
            $httpBackend.flush();
          }));

          it('gets the students subjects', function () {
            expect(scope.subjects).toEqualData(
              [{id: 1, name: 'One'}, {id: 2, name: 'Two'}, {id: 3, name: 'Three'}]
            );
          });

          it('does not set the selected subject', function () {
            expect(scope.selected.subject).toBeUndefined();
          });

          it('sets hasNoSubjects to false', inject(function ($rootScope) {
            expect($rootScope.hasNoSubjects).toEqual(false);
          }));
        });
      });

      describe('with no student subjects', function () {
        beforeEach(inject(function ($httpBackend) {
          $httpBackend.expectGET('/students/2/subjects.json').respond([]);
          deferred.resolve({ name: 'some student', id: 2 });
          scope.$apply();
          $httpBackend.flush();
        }));

        it('sets hasNoSubjects to true', inject(function ($rootScope) {
          expect($rootScope.hasNoSubjects).toEqual(true);
        }));
      });
    });

    describe('with a student_id and subject_id', function () {
      beforeEach(inject(function ($httpBackend, $location, $controller) {
        $httpBackend.expectGET('/students/2/subjects.json').respond(
          [{id: 1, name: 'One'}, {id: 2, name: 'Two'}, {id: 3, name: 'Three'}]
        );
        $location.search({student_id: 2, subject_id: 3})
        $controller('AcademicFiltersCtrl', {
          $scope: scope,
          Students: Students,
        });

        deferred.resolve({ name: 'some student', id: 2 });
        scope.$apply();
        $httpBackend.flush();
      }));

      it('sets the selected subject', inject(function ($httpBackend) {
        expect(scope.selected.subject).toEqualData({id: 3, name: 'Three'});
      }));
    });
  });


  /*--------------- Academics work controller -------------------*/
  describe('AcademicsWorkCtrl', function () {
    var scope, Units, frameworkService, httpBackend;

    beforeEach(inject(function ($rootScope, $controller, $httpBackend) {
      scope = $rootScope.$new();
      httpBackend = $httpBackend;
      frameworkService = { showFramework: jasmine.createSpy() };
      Units = { update: jasmine.createSpy().andReturn('model') };

      $controller('AcademicsWorkCtrl', {
        $scope: scope,
        Units: Units,
        frameworkService: frameworkService
      });
    }));

    describe('addUnit()', function () {
      beforeEach(function () {
        Units.add = jasmine.createSpy().andReturn('new unit');
        scope.units = ['a', 'b'];
        scope.addUnit();
      });

      it('adds the unit', function () {
        expect(Units.add).toHaveBeenCalled();
        expect(scope.units).toEqual(['new unit', 'a', 'b'])
      });
    });

    describe('deleteUnit(unit)', function () {
      var unit, confirm;

      beforeEach(inject(function(_confirm_) {
        confirm = _confirm_;
        unit = { delete: jasmine.createSpy() };
      }));

      describe('on confirm', function () {
        beforeEach(function () {
          scope.deleteUnit(unit)
        });

        it('sends a delete message to the unit', function () {
          expect(unit.delete).toHaveBeenCalled();
        });
      });

      describe('on cancel', function () {
        beforeEach(function () {
          confirm.set(false);
          scope.deleteUnit(unit)
        });

        it('does not send a delete message to the unit', function () {
          expect(unit.delete).not.toHaveBeenCalled();
        });
      });
    });

    describe('with a student and a subject set', function () {
      beforeEach(inject(function ($location, $rootScope) {
        httpBackend.expectGET('/academics/units.json?student_id=2&subject_id=5').
          respond(['unit1', 'unit2']);

        // Not testing for milestones
        httpBackend.expectGET('/students/2/student_milestones.json?subject_id=5').respond([]);

        $location.search({
          student_id: 2,
          subject_id: 5
        })
        $rootScope.$broadcast('$routeUpdate');
      }));

      it('sends a http request', function () {
        httpBackend.verifyNoOutstandingExpectation();
      });

      describe('on response', function () {
        beforeEach(function () {
          httpBackend.flush();
        });

        it('updates the Units collection', function() {
          expect(Units.update.callCount).toEqual(2);
          expect(Units.update.argsForCall[0][0]).toEqual('unit1')
          expect(Units.update.argsForCall[1][0]).toEqual('unit2')
        });

        it('sets units to the model data', function () {
          expect(scope.units).toEqual(['model', 'model']);
        });
      });

      describe('showFramework', function () {
        beforeEach(function () {
          scope.showFramework();
        });

        it('triggers the frameworkService', function () {
          expect(frameworkService.showFramework).toHaveBeenCalledWith(5, 2);
        });
      });
    });
  });
});