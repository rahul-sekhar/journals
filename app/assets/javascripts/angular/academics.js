'use strict';

angular.module('journals.academics', ['journals.people.models', 'journals.subjects', 'journals.ajax',
  'journals.confirm', 'journals.assets']).

  /*----------------- Filters controller -------------------------*/

  controller('AcademicFiltersCtrl', ['$scope', 'Students', '$location', 'ajax', '$rootScope',
    function ($scope, Students, $location, ajax, $rootScope) {
      var student_id, subject_id;

      $scope.selected = {};
      $scope.students = null;
      $scope.subjects = null;

      student_id = parseInt($location.search().student_id, 10);
      subject_id = parseInt($location.search().subject_id, 10);

      if (student_id) {
        Students.get(student_id).then(function (student) {
          $scope.setStudent(student, true);
        });
      }

      $scope.$watch('user.type', function (type) {
        if (type === 'Teacher') {
          $scope.students = Students.all();
        } else if (type === 'Student') {
          Students.get($scope.user.id).then(function (student) {
            $scope.students = [student];
            if (student_id !== student.id) {
              $scope.setStudent(student, true);
            }
          });
        } else if (type === 'Guardian') {
          $scope.students = [];
          angular.forEach($scope.user.student_ids, function (student_id) {
            Students.get(student_id).then(function (student) {
              $scope.students.push(student);
            });
          });
        }
      });

      $scope.setStudent = function (student, skipLocationChange) {
        $scope.selected.student = student;
        student_id = student.id;
        getSubjects();
        checkFilters(skipLocationChange);
        hideMenus();
      }

      $scope.setSubject = function (subject) {
        $scope.selected.subject = subject;

        if (subject) {
          subject_id = subject.id;
        } else {
          subject_id = null;
        }

        checkFilters();
        hideMenus();
      }

      function getSubjects () {
        $scope.subjects = [];

        ajax({ url: '/students/' + student_id + '/subjects' }).
          then(function(response) {
            $scope.subjects = response.data;
            if (subject_id) {
              var selected_subject = response.data.filter(function(subject) {
                return (subject.id === subject_id);
              })[0];

              $scope.setSubject(selected_subject);
            }

            if (response.data.length) {
              $rootScope.hasNoSubjects = false;
            } else {
              $rootScope.hasNoSubjects = true;
            }
          });
      }

      function checkFilters(skipLocationChange) {
        if (student_id) {
          if (!skipLocationChange) {
            $location.path('/academics/work');
          }

          $location.search({ student_id: student_id });
          if (subject_id) {
            $location.search('subject_id', subject_id);
          }
        }
      }

      function hideMenus () {
        $scope.$broadcast('hideMenus', []);
      };
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
      function getData() {
        $scope.student_id = parseInt($location.search().student_id, 10);
        $scope.subject_id = parseInt($location.search().subject_id, 10);

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
      }

      $scope.$on("$routeUpdate", function () {
        getData();
      });

      $scope.$on("frameworkClosed", function () {
        getData();
      });

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

      getData();
    }]).

  controller('StudentMilestoneDialogCtrl', ['$scope',
    function ($scope) {
      function copyData(from, to) {
        to.status = from.status;
        to.comments = from.comments;
        to.date = from.date;
      }

      $scope.newStudentMilestone = {};
      var studentMilestone;

      $scope.$watch('dialog.milestone', function (milestone) {
        if (milestone) {
          studentMilestone = milestone.student_milestone;
          copyData(studentMilestone, $scope.newStudentMilestone);
          if (!$scope.newStudentMilestone.date) {
            $scope.newStudentMilestone.date = jQuery.datepicker.formatDate('dd-mm-yy', new Date());
          }
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