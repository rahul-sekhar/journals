'use strict';

angular.module('journals.academics', ['journals.people.models', 'journals.subjects']).

  /*----------------- Filters controller -------------------------*/

  controller('AcademicFiltersCtrl', ['$scope', 'Students', 'Subjects', '$location',
    function ($scope, Students, Subjects, $location) {
      $scope.selected = {};
      $scope.students = Students.all();
      $scope.subjects = Subjects.all();

      $scope.hideMenus = function () {
        $scope.$broadcast('hideMenus', []);
      };

      function checkFilters() {
        if ($scope.selected.student && $scope.selected.subject) {
          $location.path('/academics/work')
          $location.search({
            student_id: $scope.selected.student.id,
            subject_id: $scope.selected.subject.id,
          });
        }
      }

      $scope.$watch('selected.student', checkFilters);
      $scope.$watch('selected.subject', checkFilters);
    }]).

  controller('AcademicsWorkCtrl', ['$scope',
    function ($scope) {

    }]);
