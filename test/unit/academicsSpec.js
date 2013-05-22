'use strict';

describe('academics module', function () {
  beforeEach(module('journals.academics'));

  /*------------------ Academic filters controller ----------------------*/
  describe('AcademicFiltersCtrl', function () {
    var scope, Students, Subjects, location;

    beforeEach(inject(function ($rootScope, $controller, $location) {
      scope = $rootScope.$new();
      location = $location;

      Students = { all: jasmine.createSpy().andReturn('students') };
      Subjects = { all: jasmine.createSpy().andReturn('subjects') };

      $controller('AcademicFiltersCtrl', {$scope: scope, Students: Students, Subjects: Subjects});
    }));

    it('sets selected to an empty object', function () {
      expect(scope.selected).toEqual({});
    });

    it('gets all students', function () {
      expect(Students.all).toHaveBeenCalled();
      expect(scope.students).toEqual('students');
    });

    it('gets all subjects', function () {
      expect(Subjects.all).toHaveBeenCalled();
      expect(scope.subjects).toEqual('subjects');
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

      it('sets insufficientData to true', function () {
        expect(scope.insufficientData).toEqual(true);
      })
    });

    describe('with no student', function () {
      beforeEach(function () {
        location.search({ subject_id: 5 })
        controller('AcademicsWorkCtrl', {$scope: scope});
      });

      it('sets insufficientData to true', function () {
        expect(scope.insufficientData).toEqual(true);
      })
    });

    describe('with no subject', function () {
      beforeEach(function () {
        location.search({ student_id: 2 })
        controller('AcademicsWorkCtrl', {$scope: scope});
      });

      it('sets insufficientData to true', function () {
        expect(scope.insufficientData).toEqual(true);
      })
    });

    describe('with a student and a subject', function () {
      var Units;

      beforeEach(function () {
        location.search({ student_id: 2, subject_id: 5 })
        httpBackend.expectGET('/academics/units.json?student_id=2&subject_id=5').
          respond(['unit1', 'unit2']);

        Units = { update: jasmine.createSpy().andReturn('model') };

        controller('AcademicsWorkCtrl', { $scope: scope, Units: Units });
      });

      it('sets insufficientData to false', function () {
        expect(scope.insufficientData).toEqual(false);
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
          httpBackend.expectGET('/academics/units.json?student_id=2&subject_id=5').
          respond(400);
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
    });
  });
});