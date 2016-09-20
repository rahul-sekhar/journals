'use strict';

angular.module('journals.subjects', ['journals.ajax', 'journals.collection', 'journals.model', 'journals.confirm',
  'journals.helpers', 'journals.people.models']).

  factory('Subjects', ['collection', 'model',
    function (collection, model) {
      var subjectModel = model('subject', '/academics/subjects');

      return collection(subjectModel);
    }]).

  factory('Framework', ['model', 'association', 'Milestones', 'StudentMilestone',
    function (model, association, Milestones, StudentMilestone) {
      var frameworkExtension = function (instance) {
        // Clear old student milestones
        angular.forEach(Milestones.all(), function (milestone) {
          milestone.student_milestone = StudentMilestone.create({milestone_id: milestone.id});
        });

        if (instance.student_milestones) {
          angular.forEach(instance.student_milestones, function (studentMilestone) {
            var milestone = Milestones.get(parseInt(studentMilestone.milestone_id, 10));
            if (milestone) {
              milestone.student_milestone = StudentMilestone.create(studentMilestone);
            }
          });
        }
      };

      return model('subject', '/academics/subjects', {
        extensions: [
          association('Strands', 'strand', { loaded: true, addToEnd: true }),
          frameworkExtension
        ],
        saveFields: ['name', 'column_name', 'level_numbers']
      });
    }]).

  factory('Strands', ['collection', 'model', 'association', '$filter',
    function (collection, model, association, $filter) {
      var strandExtension = function () {};

      strandExtension.setup = function (instance) {
        instance.max_level = function (minLevel) {
          var milestones, levels, maxLevel = 0;

          milestones = $filter('filterDeleted')(instance.milestones);
          if (milestones.length > 0) {
            levels = milestones.map(function (milestone) {
              return milestone.level;
            });
            maxLevel = Math.max.apply(null, levels);
          }

          return Math.max(maxLevel, minLevel || 0);
        };

        var oldUrlFn = instance.url;

        instance.url = function () {
          if (instance.isNew()) {
            return instance._parent.url() + '/add_strand'
          } else {
            return oldUrlFn();
          }
        };

        instance.nestingLevel = function () {
          var currentInstance = instance, nestingLevel = 0;

          while(currentInstance._parent !== undefined) {
            nestingLevel += 1;
            currentInstance = currentInstance._parent;
          }

          return nestingLevel;
        };
      };

      var strandsModel = model('strand', '/academics/strands', {
        extensions: [
          association('Strands', 'strand', { loaded: true, addToEnd: true }),
          association('Milestones', 'milestone', { loaded: true, addToEnd: true }),
          strandExtension
        ],
        defaultData: { milestones: [], strands: [] }
      });

      return collection(strandsModel);
    }]).

  factory('Milestones', ['collection', 'model', 'StudentMilestone',
    function (collection, model, StudentMilestone) {
      var milestoneExtension = function (instance) {};

      milestoneExtension.setup = function (instance) {
        var oldUrlFn = instance.url;

        instance.url = function () {
          if (instance.isNew()) {
            return instance._parent.url() + '/add_milestone'
          } else {
            return oldUrlFn();
          }
        };
      };

      var milestonesModel = model('milestone', '/academics/milestones', {
        extensions: [milestoneExtension],
        saveFields: ['content', 'level']
      });

      return collection(milestonesModel, { initialLoad: false });
    }]).

  factory('StudentMilestone', ['model',
    function (model) {
      var studentId = null;
      var studentMilestoneExtension = function () {};

      studentMilestoneExtension.setup = function (instance) {
        var oldUrlFn = instance.url;

        instance.url = function () {
          if (!studentId) {
            throw new Error('Student ID not set');
          }

          if (instance.isNew()) {
            return '/students/' + studentId + '/student_milestones'
          } else {
            return oldUrlFn();
          }
        };
      };

      var studentMilestoneModel = model('student_milestone', '/academics/student_milestones', {
        extensions: [studentMilestoneExtension],
        saveFields: ['status', 'comments', 'milestone_id', 'date'],
        defaultData: { status: 0 }
      });

      studentMilestoneModel.setStudent = function (_studentId_) {
        studentId = _studentId_;
      };

      return studentMilestoneModel;
    }]).

  controller('SubjectsCtrl', ['$scope', 'Subjects', 'confirm', 'frameworkService', '$location', 'subjectPeopleService',
    function ($scope, Subjects, confirm, frameworkService, $location, subjectPeopleService) {
      $scope.subjects = Subjects.all();

      $scope.add = function () {
        Subjects.add({_edit: 'name'}, true);
      };

      $scope.edit = function (subject) {
        $location.search('framework', subject.id);
      };

      $scope.delete = function (subject) {
        if (confirm('Are you sure you want to delete the subject "' + subject.name + '"?')) {
          subject.delete();
        }
      };

      $scope.showPeople = function (subject) {
        subjectPeopleService.show(subject);
      };

      function checkFramework() {
        if ($location.search().framework) {
          frameworkService.editFramework($location.search().framework);
        }
      }
      $scope.$on("$routeUpdate", checkFramework);
      checkFramework();
    }]).

  factory('frameworkService', [
    function () {
      var frameworkService = {}, scope;

      frameworkService.register = function (_scope_) {
        scope = _scope_;
      };

      frameworkService.editFramework = function (subjectId) {
        scope.edit(subjectId);
      };

      frameworkService.showFramework = function (subjectId, studentId) {
        scope.show(subjectId, studentId);
      };

      return frameworkService;
    }]).

  controller('FrameworkCtrl', ['$scope', 'frameworkService', 'ajax', 'Framework', 'confirm', '$location', 'StudentMilestone', '$rootScope',
    function ($scope, frameworkService, ajax, Framework, confirm, $location, StudentMilestone, $rootScope) {
      $scope.mode = false;

      function loadFramework(url) {
        $scope.framework = null;
        $scope.dialog = {};

        ajax({ url: url }).
          then(function (response) {
            $scope.framework = Framework.create(response.data);
          }, function () {
            $scope.mode = false;
          });
      }

      $scope.settings = function () {
        $scope.dialog.frameworkSettings = true;
      };

      $scope.edit = function (subjectId) {
        $scope.mode = 'edit';
        loadFramework('/academics/subjects/' + subjectId);
      };

      $scope.show = function (subjectId, studentId) {
        $scope.mode = 'show';
        StudentMilestone.setStudent(studentId);
        loadFramework('/academics/subjects/' + subjectId + '?student_id=' + studentId);
      };

      $scope.close = function () {
        $location.search('framework', null);
        $scope.mode = false;
        $rootScope.$broadcast('frameworkClosed');
      };

      $scope.$on('$routeChangeStart', function () {
        $scope.mode = false;
      });

      $scope.deleteMilestone = function (milestone) {
        if (confirm('Are you sure you want to delete this milestone?')) {
          milestone.delete();
        }
      };

      $scope.deleteStrand = function (strand) {
        if (confirm('Are you sure you want to delete the strand "' + strand.name + '" and all its sub-strands and milestones?')) {
          strand.delete();
        }
      };

      $scope.addMilestone = function (level, strand) {
        strand.newMilestone({_edit: 'content', level: level});
      };

      $scope.addStrand = function (parent) {
        parent.newStrand({_edit: 'name'});
      };

      $

      frameworkService.register($scope);
    }]).

  factory('SubjectPeople', ['model', 'association', 'Teachers', 'arrayHelper',
    function (model, association, Teachers, arrayHelper) {
      var subjectPeopleExtension = function () {};

      subjectPeopleExtension.setup = function (instance) {
        var remaining = []
        instance.remainingTeachers = function () {
          var teachers = instance.subject_teachers.map(function (subjectTeacher) {
            return subjectTeacher.teacher;
          });

          var diff = arrayHelper.difference(Teachers.all(), teachers)
          diff = diff.filter(function (object) {
            return !object.deleted;
          });
          arrayHelper.shallowCopy(diff, remaining);
          return remaining;
        };
      };

      return model('subject', '/academics/subjects', {
        extensions: [
          association('SubjectTeachers', 'subject_teacher', { loaded: true, addToEnd: true }),
          subjectPeopleExtension
        ]
      });
    }]).

  factory('SubjectTeachers', ['collection', 'model', 'singleAssociation', 'association',
    function (collection, model, singleAssociation, association) {
      var subjectTeachersModel = model('subject_teacher', '/subject_teachers', {
        extensions: [
          singleAssociation('Teachers', 'teacher'),
          association('Students', 'student', { addToEnd: true })
        ],
        hasParent: true,
        saveFields: ['teacher_id']
      });

      return collection(subjectTeachersModel);
    }]).

  factory('subjectPeopleService', [
    function () {
      var subjectPeopleService = {}, scope;

      subjectPeopleService.register = function (_scope_) {
        scope = _scope_;
      };

      subjectPeopleService.show = function (subject) {
        scope.show(subject);
      };

      return subjectPeopleService;
    }]).

  controller('SubjectPeopleCtrl', ['$scope', 'subjectPeopleService', 'ajax', 'SubjectPeople',
    function ($scope, subjectPeopleService, ajax, SubjectPeople) {
      $scope.dialog = {};

      $scope.show = function (subject) {
        $scope.dialog.shown = true;
        $scope.subjectPeople = null;
        $scope.selected = null;

        ajax({url: subject.url() + '/people'}).
          then(function (response) {
            $scope.subjectPeople = SubjectPeople.create(response.data);
          }, function () {
            $scope.dialog.shown = false;
          });
      };

      $scope.$watch('dialog.shown', function (value) {
        if (!value) {
          $scope.$broadcast('menuClosed');
        }
      });

      $scope.deleteTeacher = function (subjectTeacher) {
        $scope.subjectPeople.removeSubjectTeacher(subjectTeacher);

        if ($scope.selected === subjectTeacher) {
          $scope.selected = null;
        }
      };

      $scope.addTeacher = function (teacher) {
        var newSubjectTeacher = $scope.subjectPeople.newSubjectTeacher({ teacher: teacher });
        newSubjectTeacher.save();

        $scope.selected = newSubjectTeacher;
      };

      $scope.selectTeacher = function (subject_teacher) {
        $scope.selected = subject_teacher;
        $scope.$broadcast('menuClosed');
      };

      subjectPeopleService.register($scope);
    }]).

    controller('FrameworkSettingsDialogCtrl', ['$scope',
    function ($scope) {

      $scope.$watch('dialog.frameworkSettings', function (val) {
        if (val) {
          $scope.frameworkSettings = {
            column_name: $scope.framework.column_name,
            level_numbers: $scope.framework.level_numbers
          }
        }
      });

      $scope.save = function () {
        $scope.framework.updateField('column_name', $scope.frameworkSettings.column_name);
        $scope.framework.updateField('level_numbers', $scope.frameworkSettings.level_numbers);
        $scope.dialog.frameworkSettings = null;
      }
    }]);