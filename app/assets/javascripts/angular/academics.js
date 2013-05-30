'use strict';

angular.module('journals.academics', ['journals.people.models', 'journals.subjects', 'journals.ajax',
  'journals.confirm', 'journals.assets']).

  /*----------------- Filters controller -------------------------*/

  controller('AcademicFiltersCtrl', ['$scope', 'Students', '$location', 'ajax', '$rootScope',
    function ($scope, Students, $location, ajax, $rootScope) {
      $scope.selected = {};
      $rootScope.noStudentSubjects = false;
      $scope.students = Students.all();

      // Load already selected filters
      var student_id = parseInt($location.search().student_id, 10);

      if (student_id) {
        Students.get(student_id).then(function (student) {
          $scope.selected.student = student;
        });

        var subject_id = parseInt($location.search().subject_id, 10);
        ajax({ url: '/students/' + student_id + '/subjects' }).
          then(function(response) {
            $scope.subjects = response.data;
            if (subject_id) {
              $scope.selected.subject = response.data.filter(function(subject) {
                return (subject.id === subject_id);
              })[0];
            }

            if (!response.data.length) {
              $rootScope.noStudentSubjects = true;
            }
          });
      }

      function hideMenus () {
        $scope.$broadcast('hideMenus', []);
      };

      function checkFilters() {
        if ($scope.selected.student) {
          $location.path('/academics/work')
          $location.search({ student_id: $scope.selected.student.id });
          if ($scope.selected.subject) {
            $location.search('subject_id', $scope.selected.subject.id);
          }
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

  controller('AcademicsWorkCtrl', ['$scope', '$location', 'ajax', 'Units', 'confirm', 'frameworkService',
    function ($scope, $location, ajax, Units, confirm, frameworkService) {
      $scope.student_id = $location.search().student_id;
      $scope.subject_id = $location.search().subject_id;

      if ($scope.student_id && $scope.subject_id) {
        ajax({ url: '/academics/units?student_id=' + $scope.student_id + '&subject_id=' + $scope.subject_id }).
          then(function (response) {
            $scope.units = response.data.map(Units.update);
          }, function () {
            $scope.units = [];
          });

        ajax({ url: '/students/' + $scope.student_id + '/student_milestones?subject_id=' + $scope.subject_id }).
          then(function (response) {
            $scope.milestones = response.data;
          }, function () {
            $scope.milestones = [];
          });
      }

      $scope.addUnit = function () {
        $scope.units.unshift(Units.add({
          _edit: 'name',
          subject_id: $scope.subject_id,
          student_id: $scope.student_id
        }, true));
      };

      $scope.deleteUnit = function (unit) {
        if (confirm('Are you sure you want to delete the unit "' + unit.name + '"?')) {
          unit.delete();
        }
      };

      $scope.showFramework = function () {
        frameworkService.showFramework($scope.subject_id, $scope.student_id);
      };
    }]).

  controller('StudentMilestoneDialogCtrl', ['$scope',
    function ($scope) {
      function copyData(from, to) {
        to.status = from.status;
        to.comments = from.comments;
      }

      $scope.newStudentMilestone = {};
      var studentMilestone;

      $scope.$watch('dialog.milestone', function (milestone) {
        if (milestone) {
          studentMilestone = milestone.student_milestone;
          copyData(studentMilestone, $scope.newStudentMilestone);
        }
      });

      $scope.save = function () {
        var oldData = {};
        copyData(studentMilestone, oldData);
        copyData($scope.newStudentMilestone, studentMilestone);

        studentMilestone.save().
          then(null, function () {
            copyData(oldData, studentMilestone);
          });

        $scope.dialog.milestone = null;
      };
    }]).

  controller('AcademicsSummaryCtrl', ['$scope', 'ajax', '$location',
    function ($scope, ajax, $location) {
      ajax({ url: '/academics' }).
        then(function (response) {
          $scope.academics_items = response.data;
        }, function () {
          $scope.academics_items = [];
        });

      $scope.showWork = function (studentId, subjectId) {
        $location.url('/academics/work?student_id=' + studentId + '&subject_id=' + subjectId);
      }
    }]);