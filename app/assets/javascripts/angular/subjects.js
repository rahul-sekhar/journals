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
          association('Strands', 'strand', { loaded: true }),
        ]
      });
    }]).

  factory('Strands', ['collection', 'model', 'association',
    function (collection, model, association) {
      var strandExtension = function () {};

      strandExtension.setup = function (instance) {
        instance.max_level = function () {
          var levels = instance.milestones.map(function (milestone) {
            return milestone.level;
          });
          return Math.max.apply(null, levels);
        };
      };

      var strandsModel = model('strands', '/academics/strands', {
        extensions: [
          association('Strands', 'strand', { loaded: true }),
          association('Milestones', 'milestone', { loaded: true }),
          strandExtension
        ]
      });

      return collection(strandsModel);
    }]).

  factory('Milestones', ['collection', 'model',
    function (collection, model) {
      var milestonesModel = model('milestones', '/academics/milestones', {
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

  controller('FrameworkCtrl', ['$scope', 'frameworkService', 'ajax', 'Framework',
    function ($scope, frameworkService, ajax, Framework) {
      $scope.shown = false;

      $scope.show = function (subject) {
        $scope.shown = true;
        $scope.subject = subject;

        $scope.framework = null;
        ajax({ url: subject.url() }).
          then(function (response) {
            $scope.framework = Framework.create(response.data);
            console.log($scope.framework);
          }, function () {
            $scope.shown = false;
          });
      };

      $scope.close = function () {
        $scope.shown = false;
      };

      frameworkService.register($scope);
    }]);