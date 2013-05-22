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

    describe('when both subject and student are set', function () {
      beforeEach(function () {
        location.path('/some/path');
        scope.selected.student = { id: 5 };
        scope.selected.subject = { id: 10 };
        scope.$apply();
      });

      it('changes the location path', function () {
        expect(location.path()).toEqual('/academics/work');
      });

      it('changes the location search', function () {
        expect(location.search().student_id).toEqual(5);
        expect(location.search().subject_id).toEqual(10);
      });
    });

    describe('when only the subject is set', function () {
      beforeEach(function () {
        location.path('/some/path');
        scope.selected.subject = { id: 10 };
        scope.$apply();
      });

      it('does not change the location path', function () {
        expect(location.path()).toEqual('/some/path');
      });

      it('does not change the location search', function () {
        expect(location.search().student_id).toBeUndefined();
        expect(location.search().subject_id).toBeUndefined();
      });
    });

    describe('when only the student is set', function () {
      beforeEach(function () {
        location.path('/some/path');
        scope.selected.student = { id: 5 };
        scope.$apply();
      });

      it('does not change the location path', function () {
        expect(location.path()).toEqual('/some/path');
      });

      it('does not change the location search', function () {
        expect(location.search().student_id).toBeUndefined();
        expect(location.search().subject_id).toBeUndefined();
      });
    });
  });
});