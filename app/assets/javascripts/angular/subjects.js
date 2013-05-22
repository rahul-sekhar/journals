'use strict';

angular.module('journals.subjects', ['journals.ajax', 'journals.collection', 'journals.model', 'journals.confirm',
  'journals.helpers', 'journals.people.models']).

  factory('Subjects', ['collection', 'model',
    function (collection, model) {
      var subjectModel = model('subject', '/academics/subjects');

      return collection(subjectModel);
    }]).

  factory('Framework', ['model', 'association',
    function (model, association) {
      return model('subject', '/academics/subjects', {
        extensions: [
          association('Strands', 'strand', { loaded: true, addToEnd: true }),
        ]
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

  factory('Milestones', ['collection', 'model',
    function (collection, model) {
      var milestoneExtension = function () {};

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

      return collection(milestonesModel);
    }]).

  controller('SubjectsCtrl', ['$scope', 'Subjects', 'confirm', 'frameworkService', '$location', 'subjectPeopleService',
    function ($scope, Subjects, confirm, frameworkService, $location, subjectPeopleService) {

      $scope.pageTitle = 'Academic records';

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
          frameworkService.showFramework($location.search().framework);
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

      frameworkService.showFramework = function (subjectId) {
        scope.show(subjectId);
      };

      return frameworkService;
    }]).

  controller('FrameworkCtrl', ['$scope', 'frameworkService', 'ajax', 'Framework', 'confirm', '$location',
    function ($scope, frameworkService, ajax, Framework, confirm, $location) {
      $scope.shown = false;

      $scope.show = function (subjectId) {
        $scope.shown = true;

        $scope.framework = null;
        ajax({ url: '/academics/subjects/' + subjectId }).
          then(function (response) {
            $scope.framework = Framework.create(response.data);
          }, function () {
            $scope.shown = false;
          });
      };

      $scope.close = function () {
        $location.search('framework', null);
        $scope.shown = false;
      };

      $scope.$on('$routeChangeStart', function () {
        $scope.shown = false;
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
      }

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
      $scope.shown = false;

      $scope.show = function (subject) {
        $scope.shown = true;
        $scope.subjectPeople = null;
        $scope.selected = null;

        ajax({url: subject.url() + '/people'}).
          then(function (response) {
            $scope.subjectPeople = SubjectPeople.create(response.data);
            console.log($scope.subjectPeople);
          }, function () {
            $scope.shown = false;
          });
      };

      $scope.$watch('shown', function (value) {
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
      };

      subjectPeopleService.register($scope);
    }]);