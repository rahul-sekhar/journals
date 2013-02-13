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

function GuardiansCtrl($scope, $routeParams, commonPeopleCtrl) {
  commonPeopleCtrl.include($scope, 'guardians', $routeParams.id);
}

function InPlaceEditCtrl($scope, $http, errorHandler) {
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
        errorHandler.message(data);
      });
  }

  // Handler for addField events
  $scope.$on('addField', function(e, person, field) {
    if ((person.id === parent.id && person.type === parent.type) && (field === $scope.fieldName || field === $scope.displayName)) {
      $scope.editMode = true;
    }
  });
}