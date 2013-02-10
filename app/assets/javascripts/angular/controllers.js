'use strict';

/* Controllers */

function PeopleCtrl($scope, commonPeopleCtrl) {
  commonPeopleCtrl.include($scope);
}

function ArchivedPeopleCtrl($scope, commonPeopleCtrl) {
  commonPeopleCtrl.include($scope, 'archived');
}

function TeachersCtrl($scope, $routeParams, commonPeopleCtrl) {
  commonPeopleCtrl.include($scope, 'teachers', $routeParams.id);
}

function StudentsCtrl($scope, $routeParams, commonPeopleCtrl) {
  commonPeopleCtrl.include($scope, 'students', $routeParams.id);
}
