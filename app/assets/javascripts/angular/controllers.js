'use strict';

/* Controllers */

function PeopleCtrl($scope, commonPeopleCtrl) {
  commonPeopleCtrl.include($scope);
}

function TeachersCtrl($scope, $routeParams, commonPeopleCtrl) {
  commonPeopleCtrl.include($scope, 'teachers', $routeParams.id);
}

function StudentsCtrl($scope, $routeParams, commonPeopleCtrl) {
  commonPeopleCtrl.include($scope, 'students', $routeParams.id);
}
