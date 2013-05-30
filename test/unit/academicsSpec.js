'use strict';

describe('academics module', function () {
  beforeEach(module('journals.academics'));

  /*------------------ Academic filters controller ----------------------*/
  describe('AcademicFiltersCtrl', function () {
    var scope, Students, location, controller, httpBackend, deferred, rootScope;

    beforeEach(inject(function ($rootScope, $controller, $location, $q, $httpBackend) {
      rootScope = $rootScope;
      scope = $rootScope.$new();
      location = $location;
      httpBackend = $httpBackend;

      deferred = $q.defer();
      Students = {
        all: jasmine.createSpy().andReturn('students'),
        get: jasmine.createSpy().andReturn(deferred.promise)
      };

      controller = $controller;
    }));

    describe('with no student_id', function () {
      beforeEach(function () {
        controller('AcademicFiltersCtrl', {$scope: scope, Students: Students});
      });

      it('sets selected to an empty object', function () {
        expect(scope.selected).toEqual({});
      });

      it('gets all students', function () {
        expect(Students.all).toHaveBeenCalled();
        expect(scope.students).toEqual('students');
      });

      it('sets noStudentSubjects to false', function () {
        expect(rootScope.noStudentSubjects).toEqual(false);
      });
    });

    describe('with a student_id', function () {
      beforeEach(function () {
        httpBackend.expectGET('/students/2/subjects.json').respond(
          [{id: 1, name: 'One'}, {id: 2, name: 'Two'}, {id: 3, name: 'Three'}]
        );
        location.search({student_id: 2})
        controller('AcademicFiltersCtrl', {$scope: scope, Students: Students});
      });

      it('gets all students', function () {
        expect(Students.all).toHaveBeenCalled();
        expect(scope.students).toEqual('students');
      });

      it('sets noStudentSubjects to false', function () {
        expect(rootScope.noStudentSubjects).toEqual(false);
      });

      it('gets the selected student', function () {
        expect(Students.get).toHaveBeenCalledWith(2);
        deferred.resolve('some student');
        scope.$apply();
        expect(scope.selected).toEqual({ student: 'some student' });
      });

      it('sends a request for subjects', function () {
        httpBackend.verifyNoOutstandingExpectation();
      });

      describe('on response from the server', function () {
        beforeEach(function () {
          httpBackend.flush();
        });

        it('gets the students subjects', function () {
          expect(scope.subjects).toEqualData(
            [{id: 1, name: 'One'}, {id: 2, name: 'Two'}, {id: 3, name: 'Three'}]
          );
        });

        it('does not set the selected subject', function () {
          expect(scope.selected.subject).toBeUndefined();
        });

        it('does not set noStudentSubjects', function () {
          expect(rootScope.noStudentSubjects).toEqual(false);
        });
      });

      describe('with no student subjects', function () {
        beforeEach(function () {
          httpBackend.resetExpectations();
          httpBackend.expectGET('/students/2/subjects.json').respond([]);
          httpBackend.flush();
        });

        it('sets noStudentSubjects', function () {
          expect(rootScope.noStudentSubjects).toEqual(true);
        });
      });
    });

    describe('with a student_id and subject_id', function () {
      beforeEach(function () {
        httpBackend.expectGET('/students/2/subjects.json').respond(
          [{id: 1, name: 'One'}, {id: 2, name: 'Two'}, {id: 3, name: 'Three'}]
        );
        location.search({student_id: 2, subject_id: 3})
        controller('AcademicFiltersCtrl', {$scope: scope, Students: Students});
      });

      it('sets the selected subject', function () {
        httpBackend.flush();
        expect(scope.selected.subject).toEqualData({id: 3, name: 'Three'});
      });
    });
  });


  /*--------------- Academics work controller -------------------*/
  describe('AcademicsWorkCtrl', function () {
    var scope, location, controller, httpBackend;

    beforeEach(inject(function ($rootScope, $controller, $location, $httpBackend) {
      scope = $rootScope.$new();
      location = $location;
      controller = $controller;
      httpBackend = $httpBackend;
    }));

    describe('with no student or subject', function () {
      beforeEach(function () {
        controller('AcademicsWorkCtrl', {$scope: scope});
      });
    });

    describe('with no subject', function () {
      beforeEach(function () {
        location.search({ student_id: 2 })
        controller('AcademicsWorkCtrl', {$scope: scope});
      });

      it('sets the student_id', function () {
        expect(scope.student_id).toEqual(2);
      })
    });

    describe('with a student and a subject', function () {
      var Units, frameworkService;

      beforeEach(function () {
        frameworkService = { showFramework: jasmine.createSpy() };

        location.search({ student_id: 2, subject_id: 5 })
        httpBackend.expectGET('/academics/units.json?student_id=2&subject_id=5').
          respond(['unit1', 'unit2']);

        // Not testing for milestones
        httpBackend.expectGET('/students/2/student_milestones.json?subject_id=5').respond([]);

        Units = { update: jasmine.createSpy().andReturn('model') };

        controller('AcademicsWorkCtrl', { $scope: scope, Units: Units, frameworkService: frameworkService });
      });

      it('sets the student id', function () {
        expect(scope.student_id).toEqual(2);
      });

      it('sets the subject id', function () {
        expect(scope.subject_id).toEqual(5);
      });

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

      describe('on failure', function () {
        beforeEach(function () {
          httpBackend.resetExpectations();
          httpBackend.expectGET('/academics/units.json?student_id=2&subject_id=5').respond(400);
          httpBackend.expectGET('/students/2/student_milestones.json?subject_id=5').respond([]);
          httpBackend.flush();
        });

        it('sets units to an empty array', function () {
          expect(scope.units).toEqual([]);
        });
      });

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