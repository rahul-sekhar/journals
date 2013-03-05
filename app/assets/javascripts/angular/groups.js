'use strict';

angular.module('journals.groups', ['journals.messageHandler', 'journals.arrayExtensions']).

  factory('Groups', ['$http', 'messageHandler', '$q', function($http, messageHandler, $q) {
    var GroupsObj = {};
    var groups = [];

    // Create a group instance
    var create = function(inputData) {
      var group = {};
      angular.extend(group, inputData);

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

    return GroupsObj;
  }]).

  controller('GroupsCtrl', ['$scope', 'Groups', 'messageHandler', function($scope, Groups, messageHandler) {
    $scope.groups = Groups.all();
  }]);