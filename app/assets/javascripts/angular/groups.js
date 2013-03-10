'use strict';

angular.module('journals.groups', ['journals.messageHandler', 'journals.arrayHelper']).

  factory('Groups', ['$http', 'messageHandler', 'arrayHelper', '$q', '$timeout', function($http, messageHandler, arrayHelper, $q, $timeout) {
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
        messageHandler.showProcess('Deleting the group ' + group.name + '...');
        $http.delete('/groups/' + group.id).
          then(function() {
            arrayHelper.removeItem(groups, group);
            messageHandler.showNotification('The group ' + group.name + ' has been deleted.');
          }, 
          function(response) {
            delete group.deleted;
            messageHandler.showError(response, 'Group ' + group.name + ' could not be deleted.');
          });
      };

      // Rename function
      group.rename = function(new_name) {
        var old_name = group.name;
        if (old_name === new_name) return;

        group.name = new_name;
        messageHandler.showProcess('Renaming group...')
        $http.put('/groups/' + group.id, { group: { name: new_name }}).
          then(function(response) {
            group.name = response.data.name;
            messageHandler.showNotification('Group renamed to ' + new_name);
          },
          function(response) {
            group.name = old_name;
            messageHandler.showError(response, 'Group could not be renamed.');
          });
      };

      return group;
    };

    // Query groups
    var groupsPromise;
    var queryGroups = function() {
      groupsPromise = $http.get('/groups').
        then(function(response) {
          arrayHelper.shallowCopy(response.data.map(create), groups);
        }, function(response) {
          arrayHelper.shallowCopy([], groups);
          messageHandler.showError(response, 'Information about groups could not be loaded.');

          // Set a timeout for the next try
          $timeout(function() {
            groupsPromise = undefined;
          }, 30000)
          
        });
    };

    // Function to return a reference to all groups
    GroupsObj.all = function() {
      if (!groupsPromise) queryGroups();
      return groups;
    };

    // Function to get a group by ID
    GroupsObj.get = function(id) {
      if (!groupsPromise) queryGroups();
      return groupsPromise.
        then(function() {
          var group = groups.filter(function(obj) {
            return obj.id == id;
          })[0];

          if (group) {
            return group
          }
          else {
            return $q.reject('The requested group could not be found.');
          }
        });
    };

    // Function to add an empty group
    GroupsObj.add = function() {
      var new_group = {};
      new_group.editing = true;

      new_group.rename = function(new_name) {
        if (!new_name) {
          arrayHelper.removeItem(groups, new_group);
          return;
        }

        new_group.name = new_name;
        messageHandler.showProcess('Adding group ' + new_name + '...');
        $http.post('/groups', { group: { name: new_name }}).
          then(function(response) {
            var index = groups.indexOf(new_group);
            groups[index] = create(response.data);
            messageHandler.showNotification('Group ' + new_name + ' added.')
          },
          function(response) {
            arrayHelper.removeItem(groups, new_group);
            messageHandler.showError(response, 'Group ' + new_name + ' could not be added.');
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