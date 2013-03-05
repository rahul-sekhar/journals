'use strict';

angular.module('journals.groups', ['journals.messageHandler', 'journals.arrayExtensions']).

  factory('Groups', ['$http', 'messageHandler', '$q', function($http, messageHandler, $q) {
    var GroupsObj = {};
    var groups = [];

    // Create a group instance
    var create = function(inputData) {
      var group = {};
      angular.extend(group, inputData);

      // Throw an exception if the group has no ID
      if (!group.id) throw new Error('Group instance does not have an ID set');

      // Delete function
      group.delete = function() {
        group.deleted = true;
        $http.delete('/groups/' + group.id).
          then(function() {
            groups.remove(group);
          }, 
          function(response) {
            messageHandler.showError(response);
            delete group.deleted;
          });
      };

      // Rename function
      group.rename = function(new_name) {
        var old_name = group.name;
        if (old_name === new_name) return;

        group.name = new_name;
        $http.put('/groups/' + group.id, { group: { name: new_name }}).
          then(function(response) {
            group.name = response.data.name;
          },
          function(response) {
            messageHandler.showError(response);
            group.name = old_name;
          });
      };

      return group;
    };

    // Query groups
    var groupsPromise = $http.get('/groups').
      then(function(response) {
        groups.replace(response.data.map(create));
      }, function(response) {
        groups.replace([]);
        messageHandler.showError(response);
      });

    // Function to return a reference to all groups
    GroupsObj.all = function() {
      return groups;
    };

    // Function to add an empty group
    GroupsObj.add = function() {
      var new_group = {};
      new_group.editing = true;

      new_group.rename = function(new_name) {
        if (!new_name) {
          groups.remove(new_group);
          return;
        }

        new_group.name = new_name;
        $http.post('/groups', { group: { name: new_name }}).
          then(function(response) {
            angular.copy(create(response.data), new_group);
          },
          function(response) {
            messageHandler.showError(response);
            groups.remove(new_group);
          });
      };
      
      groups.unshift(new_group);
      return new_group;
    };

    return GroupsObj;
  }]).

  controller('GroupsCtrl', ['$scope', 'Groups', 'messageHandler', function($scope, Groups, messageHandler) {
    $scope.groups = Groups.all();

    $scope.add = function() {
      Groups.add();
    };
  }]);