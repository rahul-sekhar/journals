'use strict';

angular.module('journals.people.controllers', ['journals.people']).
  
  /*--------- People base controller ---------*/

  factory('PeopleBaseCtrl', ['$location', function($location) {
    return function($scope) {
      $scope.doSearch = function(value) {
        $location.search('search', value).replace();
      };

      // Handle parameter changes
      $scope.$on("$routeUpdate", function() {
        $scope.load();
      });

      // Initial load
      $scope.load();
    };
  }]).

  /*--------- Service to load a people collection -------- */

  factory('loadPeopleCollection', ['peopleInterface', '$location',
    function(peopleInterface, $location) {

    return function($scope) {
      $scope.load = function() {
        peopleInterface.load($location.url()).
          then(function(data) {
            $scope.people = data.people;
            $scope.totalPages = data.metadata.total_pages;
            $scope.currentPage = data.metadata.current_page;
          });
      };
    };
  }]).


  /*--------- Service to load a profile -------- */

  factory('loadProfile', ['peopleInterface', '$location',
    function(peopleInterface, $location) {

    return function($scope) {
      $scope.load = function() {
        peopleInterface.loadProfile($location.url()).
          then(function(data) {
            $scope.people = data.people;
            $scope.pageTitle = 'Profile: ' + data.name;
          },
          function() {
            $scope.pageTitle = 'Profile: Not found';
          });
      };
    };
  }]).


  /*-------- Profile controller -----------*/

  controller('ProfileCtrl', ['$scope', 'PeopleBaseCtrl', 'loadProfile',
    function($scope, PeopleBaseCtrl, loadProfile) {

    $scope.pageTitle = 'Profile';
    $scope.profile = true

    loadProfile($scope);
    PeopleBaseCtrl($scope);
  }]).

  
  /*--------- People page ---------*/

  controller('PeopleCtrl', ['$scope', 'PeopleBaseCtrl', 'loadPeopleCollection',
    function($scope, PeopleBaseCtrl, loadPeopleCollection) {

    $scope.pageTitle = 'People';
    $scope.canAddStudent = true;
    $scope.canAddTeacher = true;
    $scope.filterName = 'Students and teachers';

    loadPeopleCollection($scope);
    PeopleBaseCtrl($scope);
  }]).


  /*--------- Archived people page ---------*/

  controller('ArchivedPeopleCtrl', ['$scope', 'PeopleBaseCtrl', 'loadPeopleCollection',
    function($scope, PeopleBaseCtrl, loadPeopleCollection) {

    $scope.pageTitle = 'Archived';
    $scope.canAddStudent = false;
    $scope.canAddTeacher = false;
    $scope.filterName = 'Archived students and teachers';

    loadPeopleCollection($scope);
    PeopleBaseCtrl($scope);
  }]).


  /*--------- Teachers page ---------*/

  controller('TeachersCtrl', ['$scope', 'PeopleBaseCtrl', 'loadPeopleCollection',
    function($scope, PeopleBaseCtrl, loadPeopleCollection) {

    $scope.pageTitle = 'Teachers';
    $scope.canAddStudent = false;
    $scope.canAddTeacher = true;
    $scope.filterName = 'Teachers';

    loadPeopleCollection($scope);
    PeopleBaseCtrl($scope);
  }]).


  /*--------- Students page ---------*/

  controller('StudentsCtrl', ['$scope', 'PeopleBaseCtrl', 'loadPeopleCollection',
    function($scope, PeopleBaseCtrl, loadPeopleCollection) {

    $scope.pageTitle = 'Students';
    $scope.canAddStudent = true;
    $scope.canAddTeacher = false;
    $scope.filterName = 'Students';

    loadPeopleCollection($scope);
    PeopleBaseCtrl($scope);
  }]);