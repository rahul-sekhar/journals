'use strict';

angular.module('journals.academics', ['journals.people.models', 'journals.subjects', 'journals.ajax', 'journals.confirm']).

  /*----------------- Filters controller -------------------------*/

  controller('AcademicFiltersCtrl', ['$scope', 'Students', 'Subjects', '$location',
    function ($scope, Students, Subjects, $location) {
      $scope.selected = {};

      $scope.students = Students.all();
      $scope.subjects = Subjects.all();

      // Load already selected filters
      var student_id = parseInt($location.search().student_id, 10);
      var subject_id = parseInt($location.search().subject_id, 10);

      if (student_id) {
        Students.get(student_id).then(function (student) {
          $scope.selected.student = student;
        });
      }
      if (subject_id) {
        Subjects.get(subject_id).then(function (subject) {
          $scope.selected.subject = subject;
        });
      }

      function hideMenus () {
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

      $scope.setStudent = function (student) {
        $scope.selected.student = student;
        checkFilters();
        hideMenus();
      }

      $scope.setSubject = function (subject) {
        $scope.selected.subject = subject;
        checkFilters();
        hideMenus();
      }
    }]).

  factory('Units', ['collection', 'model',
    function (collection, model) {
      var unitsModel = model('unit', '/academics/units', {
        saveFields: ['name', 'started_date', 'due_date', 'completed_date', 'comments', 'student_id', 'subject_id']
      });

      return collection(unitsModel);
    }]).

  controller('AcademicsWorkCtrl', ['$scope', '$location', 'ajax', 'Units', 'confirm',
    function ($scope, $location, ajax, Units, confirm) {
      var student_id = $location.search().student_id;
      var subject_id = $location.search().subject_id;

      if (student_id && subject_id) {
        $scope.insufficientData = false;

        ajax({ url: '/academics/units?student_id=' + student_id + '&subject_id=' + subject_id }).
          then(function (response) {
            $scope.units = response.data.map(Units.update);
          }, function () {
            $scope.units = [];
          });
      } else {
        $scope.insufficientData = true;
      }

      $scope.addUnit = function () {
        $scope.units.unshift(Units.add({_edit: 'name', subject_id: subject_id, student_id: student_id}, true));
      };

      $scope.deleteUnit = function (unit) {
        if (confirm('Are you sure you want to delete the unit "' + unit.name + '"?')) {
          unit.delete();
        }
      };
    }]);
