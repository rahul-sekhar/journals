'use strict';

/* Services */

angular.module('journalsApp.services', ['ngResource', 'journalsApp.filters']).

  factory('Group', function($resource) {
    return $resource('/groups/:id', {id: "@id"});
  }).
  
  factory('dialogHandler', function() {
    var dialogHandler = {};
    
    dialogHandler.message = function(message) {
      console.log("ERROR: " + message);
    };

    return dialogHandler;
  });