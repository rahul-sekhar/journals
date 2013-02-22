'use strict';

/* Controllers */

function PeopleCtrl($scope, Person, PeopleCtrlBase) {
  $scope.filterName = 'Students and teachers';
  PeopleCtrlBase.include($scope, Person.query);
}

function ArchivedPeopleCtrl($scope, Person, PeopleCtrlBase) {
  $scope.filterName = 'Archived students and teachers';
  PeopleCtrlBase.include($scope, Person.query_archived);
}

function TeachersCtrl($scope, Person, PeopleCtrlBase) {
  $scope.filterName = 'Teachers';
  PeopleCtrlBase.include($scope, Person.query_teachers);
}

function StudentsCtrl($scope, Person, PeopleCtrlBase) {
  $scope.filterName = 'Students';
  PeopleCtrlBase.include($scope, Person.query_students);
}

function SingleTeacherCtrl($scope, $routeParams, Person) {
  $scope.pageTitle = 'Profile';
  $scope.singleProfile = true;
  Person.get({ id: $routeParams.id, type: 'teachers' },
    // Success - load the profile
    function(result) {
      $scope.pageTitle = 'Profile: ' + result.full_name;
      $scope.people = [result];
    },
    // Failure - profile not found 
    function() {
      $scope.pageTitle = 'Profile: Not found';
      $scope.people = [];
    }
  );
}

function SingleStudentCtrl($scope, $routeParams, Person) {
  $scope.pageTitle = 'Profile';
  $scope.singleProfile = true;
  Person.get({ id: $routeParams.id, type: 'students' },
    // Success - load the profile
    function(result) {
      $scope.pageTitle = 'Profile: ' + result.full_name;
      $scope.people = [result];
    },
    // Failure - profile not found 
    function() {
      $scope.pageTitle = 'Profile: Not found';
      $scope.people = [];
    }
  );
}

function SingleGuardianCtrl($scope, $routeParams, Person) {
  $scope.pageTitle = 'Profile';
  $scope.singleProfile = true;
  Person.get({ id: $routeParams.id, type: 'guardians' },
    // Success - load the array of students
    function(result) {
      $scope.pageTitle = 'Profile: ' + result.full_name;
      $scope.people = result.students
    },
    // Failure - profile not found 
    function() {
      $scope.pageTitle = 'Profile: Not found';
      $scope.people = [];
    }
  );
}

function FieldsCtrl($scope, profileFields) {
  var person = $scope.person;

  $scope.dateFields = profileFields.date[person.type];
  $scope.standardFields = profileFields.standard[person.type];
  $scope.multiLineFields = profileFields.multiLine[person.type];

  $scope.remainingFields = function() {
    // Handle date fields first
    var fields = profileFields.date[person.type].filter(function(element) {
      return !person['formatted_' + element];
    });

    // Handle other fields
    fields = fields.concat(profileFields.standard[person.type]).concat(profileFields.multiLine[person.type]);

    return fields.filter(function(element) {
      return !person[element];
    });
  };

  $scope.addField = function(fieldName) {
    $scope.$broadcast("addField", fieldName);
  }
}

function InPlaceEditCtrl($scope, $http, dialogHandler) {
  $scope.editMode = false;
  var parent = $scope.parent;

  $scope.startEdit = function() {
    $scope.editorValue = null;
    $scope.editorValue = parent[$scope.fieldName];
    $scope.editMode = true;
  }

  $scope.cancelEdit = function() {
    $scope.editMode = false;
  }

  $scope.clearEdit = function() {
    $scope.editorValue = null;
    $scope.finishEdit();
  }

  $scope.finishEdit = function() {
    var old_val = parent[$scope.fieldName];
    var new_val = $scope.editorValue;
    $scope.editMode = false;

    // Return if no change was made
    if (old_val === new_val) return;

    // Update the parent field
    parent[$scope.fieldName] = new_val;

    // Compile data to be sent to the server
    var profile_data = {};
    profile_data[$scope.fieldName] = new_val;
    var data = {};
    data[parent.type.slice(0, -1)] = profile_data;

    // Send the data to the server
    $http.put( '/' + parent.type + '/' + parent.id, data, { timeout: 4000 }).

      // Update the field according to the response on success
      success(function(data) {
        parent[$scope.fieldName] = data[$scope.fieldName]
      }).

      // Reset the field and show an error on failure
      error(function(data, status) {
        parent[$scope.fieldName] = old_val;
        dialogHandler.message(data);
      });
  }

  // Handler for addField events
  $scope.$on('addField', function(e, field) {
    if ((field === $scope.fieldName || field === $scope.displayName)) {
      $scope.editMode = true;
    }
  });
}