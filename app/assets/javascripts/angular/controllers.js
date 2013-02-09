'use strict';

/* Controllers */

function PeopleCtrl($scope, Person) {
  $scope.people = Person.query();
}
PeopleCtrl.$inject = ['$scope', 'Person'];