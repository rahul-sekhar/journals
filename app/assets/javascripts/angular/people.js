'use strict';

angular.module('journals.people', ['journals.messageHandler']).
  

  /*------- Controllers ----------*/
  
  controller('PeopleCtrl', ['$scope', '$route', '$routeParams', '$location', 'PeopleInterface', 'messageHandler',
      function($scope, $route, $routeParams, $location, PeopleInterface, messageHandler) {
    
    var loadPeople;
    var id = $routeParams.id;

    // For a single person
    if (id) {
      $scope.singlePerson = true;
      $scope.pageTitle = 'Profile';

      loadPeople = function() {
        PeopleInterface.get($location.url()).
          then(function(result) {
            $scope.people = [result.person];
            $scope.pageTitle = 'Profile: ' + result.person.full_name;
          }, function(message) {
            messageHandler.showError(message);
            $scope.pageTitle = 'Profile not found';
          });
      };
    }

    // For pages of people
    else {
      $scope.filterName = $route.current.filterName;
      $scope.singlePerson = false;
      $scope.pageTitle = 'People';

      loadPeople = function() {
        PeopleInterface.query($location.url()).
          then(function(result) {
            $scope.people = result.people;
            $scope.currentPage = result.metadata.currentPage;
            $scope.totalPages = result.metadata.totalPages;
          }, function(message) {
            messageHandler.showError(message);
          });
      };

      $scope.doSearch = function(val) {
        $location.search('search', val).replace();
      };
    }

    // Handle changes in route params
    $scope.$on("$routeUpdate", function() {
      loadPeople();
    });

    // Initial load
    loadPeople();
  }]).


  /*------- Models ----------*/

  factory('Person', function() {
    var Person = {};

    Person.create = function() {

    };

    Person.createFromArray = function() {

    };

    return Person;
  }).
  
  factory('PeopleInterface', ['$q', '$http', 'Person', function($q, $http, Person) {
    var PeopleInterface = {};

    PeopleInterface.query = function(url) {
      var deferred = $q.defer();
      $http.get(url).
        then(function(response) {
          var result = {};
          result.people = Person.createFromArray(response.data.items);
          result.metadata = response.data;
          delete result.metadata.items;
          deferred.resolve(result);
        }, 
        function(response) {
          deferred.reject(response);
        });
      return deferred.promise;
    };

    PeopleInterface.get = function(url) {
      var deferred = $q.defer();
      $http.get(url).
        then(function(response) {
          var result = {};
          result.person = Person.create(response.data);
          deferred.resolve(result);
        }, 
        function(response) {
          deferred.reject(response);
        });
      return deferred.promise;
    };

    return PeopleInterface;
  }]);
