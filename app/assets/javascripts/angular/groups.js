'use strict';

angular.module('journals.groups', ['journals.messageHandler', 'journals.arrayHelper', 'journals.cachedCollection']).

  factory('Groups', ['$http', 'messageHandler', 'arrayHelper', '$q', '$timeout', '$window', 'cachedCollection',
    function($http, messageHandler, arrayHelper, $q, $timeout, $window, cachedCollection) {

    var GroupsObj = {};

    // Create a group instance
    var create = function(inputData) {
      var group = {};
      angular.extend(group, inputData);

      // Throw an exception if the group has no ID
      if (!group.id) throw new Error('Group instance does not have an ID set');

      // Delete function
      group.delete = function() {
        var conf = $window.confirm('Are you sure you want to delete the group "' + group.name + '"');
        if (!conf) return;

        group.deleted = true;
        $http.delete('/groups/' + group.id).
          then(function() {
            arrayHelper.removeItem(groups, group);
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
        $http.put('/groups/' + group.id, { group: { name: new_name }}).
          then(function(response) {
            group.name = response.data.name;
          },
          function(response) {
            group.name = old_name;
            messageHandler.showError(response, 'Group could not be renamed.');
          });
      };

      return group;
    };

    var groupsCollection = cachedCollection('/groups', 'group', create);
    var groups = groupsCollection.collection;
    GroupsObj.all = groupsCollection.all;
    GroupsObj.get = groupsCollection.get;

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
        $http.post('/groups', { group: { name: new_name }}).
          then(function(response) {
            var index = groups.indexOf(new_group);
            groups[index] = create(response.data);
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