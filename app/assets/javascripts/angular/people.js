'use strict';

angular.module('journals.people', ['journals.people.models', 'journals.people.directives', 'journals.confirm']).

  /*--------- People base controller ---------*/

  factory('peopleBaseCtrl', ['$location', 'confirm', '$timeout', function ($location, confirm, $timeout) {
    return function ($scope) {
      $scope.doSearch = function (value) {
        $location.search('search', value).replace();
      };

      // Handle deleting profiles
      $scope.delete = function (profile) {
        var message = 'Are you sure you want to delete the profile for "' + profile.full_name + '"?' +
          'Anything that has been created by that person will be lost. ' +
          'You can archive the profile if you don\'t want to lose data.';

        if (confirm(message)) {
          profile.delete();
        }
      };

      // Handle resetting passwords/activating profiles
      $scope.resetPassword = function (profile) {
        var action, message;

        action = profile.active ? 'reset the password for' : 'activate';
        message = 'Are you sure you want to ' + action + ' "' + profile.full_name +
          '? A randomly generated password will be emailed to ' + profile.email + '.';

        if (confirm(message)) {
          profile.resetPassword();
        }
      };

      // Handle toggling archive
      $scope.toggleArchive = function (profile) {
        var message = 'Are you sure you want to archive "' + profile.full_name +
            '"? Their data will remain but the user will not be able to log in.';

        if (profile.archived || confirm(message)) {
          profile.toggleArchive();
        }
      };

      // Handle adding a guardian
      $scope.addGuardian = function (profile) {
        var guardian = profile.newGuardian();
        $timeout(function() {
          $scope.$broadcast('editField', guardian, 'full_name');
        }, 0);
      };

      // Handle removing guardians
      $scope.removeGuardian = function (profile, guardian) {
        var message = 'Are you sure you want to delete the guardian "' + guardian.full_name + '"?' +
          'Anything that has been created by that guardian will be lost.';

        // Skip confirm if the guardian has more than 1 student
        if ((guardian.parent_count > 1) || confirm(message)) {
          profile.removeGuardian(guardian);
        }
      };

      // Handle parameter changes
      $scope.$on("$routeUpdate", function () {
        $scope.load();
      });

      // Initial load
      $scope.load();
    };
  }]).

  /*--------- Service to load a people collection -------- */

  factory('peopleCollectionMixin', ['peopleInterface', '$location', 'Groups', '$timeout',
    function (peopleInterface, $location, Groups, $timeout) {
      return function ($scope) {
        $scope.load = function () {
          peopleInterface.load($location.url()).
            then(function (data) {
              $scope.people = data.people;
              $scope.totalPages = data.metadata.total_pages;
              $scope.currentPage = data.metadata.current_page;
            });
        };

        $scope.groups = Groups.all();

        // Handle adding profiles
        $scope.addTeacher = function() {
          var teacher = peopleInterface.addTeacher();
          $scope.people.unshift(teacher);
          $timeout(function () {
            $scope.$broadcast('editField', teacher, 'full_name');
          }, 0);
        };

        $scope.addStudent = function() {
          var student = peopleInterface.addStudent();
          $scope.people.unshift(student);
          $timeout(function () {
            $scope.$broadcast('editField', student, 'full_name');
          }, 0);
        };
      };
    }]).


  /*--------- Service to load a profile -------- */

  factory('loadProfile', ['peopleInterface', '$location',
    function (peopleInterface, $location) {
      return function ($scope) {
        $scope.load = function () {
          peopleInterface.loadProfile($location.url()).
            then(function (data) {
              $scope.people = data.people;
              $scope.pageTitle = 'Profile: ' + data.name;
            }, function () {
              $scope.pageTitle = 'Profile: Not found';
            });
        };
      };
    }]).


  /*-------- Profile controller -----------*/

  controller('ProfileCtrl', ['$scope', 'peopleBaseCtrl', 'loadProfile',
    function ($scope, peopleBaseCtrl, loadProfile) {
      $scope.pageTitle = 'Profile';
      $scope.profile = true;

      loadProfile($scope);
      peopleBaseCtrl($scope);
    }]).


  /*--------- People page ---------*/

  controller('PeopleCtrl', ['$scope', 'peopleBaseCtrl', 'peopleCollectionMixin',
    function ($scope, peopleBaseCtrl, peopleCollectionMixin) {
      $scope.pageTitle = 'People';
      $scope.canAddStudent = true;
      $scope.canAddTeacher = true;
      $scope.filterName = 'Students and teachers';

      peopleCollectionMixin($scope);
      peopleBaseCtrl($scope);
    }]).


  /*--------- Archived people page ---------*/

  controller('ArchivedPeopleCtrl', ['$scope', 'peopleBaseCtrl', 'peopleCollectionMixin',
    function ($scope, peopleBaseCtrl, peopleCollectionMixin) {
      $scope.pageTitle = 'Archived';
      $scope.canAddStudent = false;
      $scope.canAddTeacher = false;
      $scope.filterName = 'Archived students and teachers';

      peopleCollectionMixin($scope);
      peopleBaseCtrl($scope);
    }]).


  /*--------- Teachers page ---------*/

  controller('TeachersCtrl', ['$scope', 'peopleBaseCtrl', 'peopleCollectionMixin',
    function ($scope, peopleBaseCtrl, peopleCollectionMixin) {
      $scope.pageTitle = 'Teachers';
      $scope.canAddStudent = false;
      $scope.canAddTeacher = true;
      $scope.filterName = 'Teachers';

      peopleCollectionMixin($scope);
      peopleBaseCtrl($scope);
    }]).


  /*--------- Students page ---------*/

  controller('StudentsCtrl', ['$scope', 'peopleBaseCtrl', 'peopleCollectionMixin',
    function ($scope, peopleBaseCtrl, peopleCollectionMixin) {
      $scope.pageTitle = 'Students';
      $scope.canAddStudent = true;
      $scope.canAddTeacher = false;
      $scope.filterName = 'Students';

      peopleCollectionMixin($scope);
      peopleBaseCtrl($scope);
    }]).


  /*--------- Mentees page ---------*/

  controller('MenteesCtrl', ['$scope', 'peopleBaseCtrl', 'peopleCollectionMixin',
    function ($scope, peopleBaseCtrl, peopleCollectionMixin) {
      $scope.pageTitle = 'Mentees';
      $scope.canAddStudent = false;
      $scope.canAddTeacher = false;
      $scope.filterName = 'Your mentees';

      peopleCollectionMixin($scope);
      peopleBaseCtrl($scope);
    }]).


   /*--------- Groups page ---------*/

  controller('GroupsPageCtrl', ['$scope', 'peopleBaseCtrl', 'peopleCollectionMixin', 'Groups', '$routeParams',
    function ($scope, peopleBaseCtrl, peopleCollectionMixin, Groups, $routeParams) {
      var id;

      $scope.pageTitle = 'Group';
      $scope.filterName = 'Group';

      id = parseInt($routeParams.id, 10);

      Groups.get(id).
        then(function (group) {
          $scope.pageTitle = 'Group: ' + group.name;
          $scope.filterName = group.name;
        }, function () {
          $scope.pageTitle = 'Group: Not found';
          $scope.filterName = 'Unknown group';
        });

      $scope.canAddStudent = false;
      $scope.canAddTeacher = false;

      peopleCollectionMixin($scope);
      peopleBaseCtrl($scope);
    }]);