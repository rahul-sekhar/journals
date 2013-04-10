'use strict';

angular.module('journals.people', ['journals.people.models', 'journals.people.directives', 'journals.confirm',
  'journals.searchFilters']).

  /*--------- People base controller ---------*/

  factory('peopleBaseCtrl', ['confirm', function (confirm) {
    return function ($scope) {
      // Handle deleting profiles
      $scope.delete = function (profile) {
        var message = 'Are you sure you want to delete the profile for "' + profile.name + '"?' +
          'Anything that has been created by that person will be lost. ' +
          'You can archive the profile if you don\'t want to lose data.';

        if (confirm(message)) {
          profile.delete();
        }
      };

      // Remove associations
      $scope.removeGroup = function (profile, group) {
        var message = 'Are you sure you want to remove ' + profile.name +
          'from the group ' + group.name + '?';

        if (confirm(message)) {
          profile.removeGroup(group);
        }
      };

      $scope.removeMentor = function (profile, mentor) {
        var message = 'Are you sure you want to remove the mentor ' + mentor.name +
          ' for ' + profile.name + '?';

        if (confirm(message)) {
          profile.removeMentor(mentor);
        }
      };

      $scope.removeMentee = function (profile, mentee) {
        var message = 'Are you sure you want to remove the mentee ' + mentee.name +
          ' for ' + profile.name + '?';

        if (confirm(message)) {
          profile.removeMentee(mentee);
        }
      };

      // Handle resetting passwords/activating profiles
      $scope.resetPassword = function (profile) {
        var action, message;

        action = profile.active ? 'reset the password for' : 'activate';
        message = 'Are you sure you want to ' + action + ' "' + profile.name +
          '? A randomly generated password will be emailed to ' + profile.email + '.';

        if (confirm(message)) {
          profile.resetPassword();
        }
      };

      // Handle toggling archive
      $scope.toggleArchive = function (profile) {
        var message = 'Are you sure you want to archive "' + profile.name +
            '"? Their data will remain but the user will not be able to log in.';

        if (profile.archived || confirm(message)) {
          profile.toggleArchive();
        }
      };

      // Handle adding a guardian
      $scope.addGuardian = function (profile) {
        profile.newGuardian({ _edit: 'name' });
      };

      // Handle removing guardians
      $scope.removeGuardian = function (profile, guardian) {
        var message = 'Are you sure you want to delete the guardian "' + guardian.name + '"?' +
          'Anything that has been created by that guardian will be lost.';

        // Skip confirm if the guardian has more than 1 student
        if ((guardian.parent_count > 1) || confirm(message)) {
          profile.removeGuardian(guardian);
        }
      };
    };
  }]).


  /*-------- Profile controller -----------*/

  controller('ProfileCtrl', ['$scope', 'peopleBaseCtrl', 'peopleInterface', '$location',
    function ($scope, peopleBaseCtrl, peopleInterface, $location) {
      $scope.pageTitle = 'Profile';
      $scope.profile = true;

      peopleInterface.loadProfile($location.url()).
        then(function (data) {
          $scope.people = data.people;
          $scope.pageTitle = 'Profile: ' + data.name;
        }, function () {
          $scope.people = [];
          $scope.pageTitle = 'Profile: Not found';
        });

      peopleBaseCtrl($scope);
    }]).


  /*--------- People page ---------*/

  controller('PeopleCtrl', ['$scope', 'peopleBaseCtrl', '$location', 'Groups', 'peopleInterface', 'searchFilters',
    function ($scope, peopleBaseCtrl, $location, Groups, peopleInterface, searchFilters) {
      var loadFn, searchFiltersObj;

      $scope.pageTitle = 'People';
      $scope.filters = {};

      loadFn = function () {
        peopleInterface.load($location.url()).
          then(function (data) {
            $scope.people = data.people;
            $scope.totalPages = data.metadata.total_pages;
            $scope.currentPage = data.metadata.current_page;

            $scope.$broadcast('peopleLoaded');
          });

        angular.extend($scope.filters, searchFiltersObj.getCurrentValues());
      };

      searchFiltersObj = searchFilters('search', 'filter');

      $scope.filter = function (filter, value) {
        $scope.filters[filter] = value;
        searchFiltersObj.filter(filter, value);
      };

      $scope.$watch('filters.filter', function (filterVal) {
        if (filterVal === 'archived') {
          $scope.filterName = 'Archived students and teachers';
        } else if (filterVal === 'students') {
          $scope.filterName = 'Students';
        } else if (filterVal === 'teachers') {
          $scope.filterName = 'Teachers';
        } else if (filterVal === 'mentees') {
          $scope.filterName = 'Your mentees';
        } else if (String(filterVal).substr(0, 6) === 'group-') {
          var id = parseInt(filterVal.substr(6), 10);
          Groups.get(id).
            then(function (group) {
              $scope.filterName = group.name;
            });
          $scope.filterName = '';
        }
        else {
          $scope.filterName = 'Students and teachers';
        }
      });

      $scope.groups = Groups.all();

      $scope.showGroupsDialog = function() {
        $scope.dialogs.manageGroups = true;
      };

      function clearFiltersAndDo(afterFn) {
        if (Object.keys($location.search()).length === 0) {
          afterFn();
        } else {
          var unbind = $scope.$on('peopleLoaded', function () {
            unbind();
            afterFn();
          });
          $location.search({}).replace();
        }
      }

      // Handle adding profiles
      $scope.addTeacher = function() {
        clearFiltersAndDo(function () {
          var teacher = peopleInterface.addTeacher({ _edit: 'name' });
          $scope.people.unshift(teacher);
        });
      };

      $scope.addStudent = function() {
        clearFiltersAndDo(function () {
          var student = peopleInterface.addStudent({ _edit: 'name' });
          $scope.people.unshift(student);
        });
      };

      peopleBaseCtrl($scope);

      // Handle parameter changes
      $scope.$on("$routeUpdate", function () {
        loadFn();
      });

      // Initial load
      loadFn();
    }]);