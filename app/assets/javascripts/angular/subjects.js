'use strict';

angular.module('journals.subjects', ['journals.ajax', 'journals.collection', 'journals.model', 'journals.confirm']).

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
        instance.max_level = function () {
          var milestones, levels;

          milestones = $filter('filterDeleted')(instance.milestones);
          if (milestones.length > 0) {
            levels = milestones.map(function (milestone) {
              return milestone.level;
            });
            return Math.max.apply(null, levels);
          }
          else {
            return 0;
          }
        };

        var oldUrlFn = instance.url;

        instance.url = function () {
          if (instance.isNew()) {
            return instance._parent.url() + '/add_strand'
          } else {
            return oldUrlFn();
          }
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

  controller('SubjectsCtrl', ['$scope', 'Subjects', 'confirm', 'frameworkService',
    function ($scope, Subjects, confirm, frameworkService) {

      $scope.pageTitle = 'Academic records';

      $scope.subjects = Subjects.all();

      $scope.add = function () {
        Subjects.add({_edit: 'name'}, true);
      };

      $scope.edit = function (subject) {
        frameworkService.showFramework(subject);
      };

      $scope.delete = function (subject) {
        if (confirm('Are you sure you want to delete the subject "' + subject.name + '"?')) {
          subject.delete();
        }
      };
    }]).

  factory('frameworkService', [
    function () {
      var frameworkService = {}, scope;

      frameworkService.register = function (_scope_) {
        scope = _scope_;
      };

      frameworkService.showFramework = function (subject) {
        scope.show(subject);
      };

      return frameworkService;
    }]).

  controller('FrameworkCtrl', ['$scope', 'frameworkService', 'ajax', 'Framework', 'confirm',
    function ($scope, frameworkService, ajax, Framework, confirm) {
      $scope.shown = false;

      $scope.show = function (subject) {
        $scope.shown = true;
        $scope.subject = subject;

        $scope.framework = null;
        ajax({ url: subject.url() }).
          then(function (response) {
            $scope.framework = Framework.create(response.data);
          }, function () {
            $scope.shown = false;
          });
      };

      $scope.close = function () {
        $scope.shown = false;
      };

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
    }]);