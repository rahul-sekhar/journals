'use strict';

angular.module('journals.people', ['journals.people.models', 'journals.people.directives', 'journals.confirm']).

  /*--------- People base controller ---------*/

  factory('peopleBaseCtrl', ['$location', 'confirm', function ($location, confirm) {
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

      // Handle removing guardians
      $scope.removeGuardian = function (profile, guardian) {
        var message = 'Are you sure you want to delete the guardian "' + guardian.full_name + '"?' +
          'Anything that has been created by that guardian will be lost.';

        // Skip confirm if the guardian has more than 1 student
        if ((guardian.number_of_students > 1) || confirm(message)) {
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

  factory('loadPeopleCollection', ['peopleInterface', '$location', 'Groups',
    function (peopleInterface, $location, Groups) {
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

  controller('PeopleCtrl', ['$scope', 'peopleBaseCtrl', 'loadPeopleCollection',
    function ($scope, peopleBaseCtrl, loadPeopleCollection) {
      $scope.pageTitle = 'People';
      $scope.canAddStudent = true;
      $scope.canAddTeacher = true;
      $scope.filterName = 'Students and teachers';

      loadPeopleCollection($scope);
      peopleBaseCtrl($scope);
    }]).


  /*--------- Archived people page ---------*/

  controller('ArchivedPeopleCtrl', ['$scope', 'peopleBaseCtrl', 'loadPeopleCollection',
    function ($scope, peopleBaseCtrl, loadPeopleCollection) {
      $scope.pageTitle = 'Archived';
      $scope.canAddStudent = false;
      $scope.canAddTeacher = false;
      $scope.filterName = 'Archived students and teachers';

      loadPeopleCollection($scope);
      peopleBaseCtrl($scope);
    }]).


  /*--------- Teachers page ---------*/

  controller('TeachersCtrl', ['$scope', 'peopleBaseCtrl', 'loadPeopleCollection',
    function ($scope, peopleBaseCtrl, loadPeopleCollection) {
      $scope.pageTitle = 'Teachers';
      $scope.canAddStudent = false;
      $scope.canAddTeacher = true;
      $scope.filterName = 'Teachers';

      loadPeopleCollection($scope);
      peopleBaseCtrl($scope);
    }]).


  /*--------- Students page ---------*/

  controller('StudentsCtrl', ['$scope', 'peopleBaseCtrl', 'loadPeopleCollection',
    function ($scope, peopleBaseCtrl, loadPeopleCollection) {
      $scope.pageTitle = 'Students';
      $scope.canAddStudent = true;
      $scope.canAddTeacher = false;
      $scope.filterName = 'Students';

      loadPeopleCollection($scope);
      peopleBaseCtrl($scope);
    }]).


  /*--------- Mentees page ---------*/

  controller('MenteesCtrl', ['$scope', 'peopleBaseCtrl', 'loadPeopleCollection',
    function ($scope, peopleBaseCtrl, loadPeopleCollection) {
      $scope.pageTitle = 'Mentees';
      $scope.canAddStudent = false;
      $scope.canAddTeacher = false;
      $scope.filterName = 'Your mentees';

      loadPeopleCollection($scope);
      peopleBaseCtrl($scope);
    }]).


   /*--------- Groups page ---------*/

  controller('GroupsPageCtrl', ['$scope', 'peopleBaseCtrl', 'loadPeopleCollection', 'Groups', '$routeParams',
    function ($scope, peopleBaseCtrl, loadPeopleCollection, Groups, $routeParams) {
      var id;

      $scope.pageTitle = 'Group';
      $scope.filterName = 'Group';

      id = parseInt($routeParams.id, 10)
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

      loadPeopleCollection($scope);
      peopleBaseCtrl($scope);
    }]);