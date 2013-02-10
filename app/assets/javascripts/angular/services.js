'use strict';

/* Services */

angular.module('journalsApp.services', ['ngResource']).

  factory('Person', function($resource) {
    return $resource('/:type/:id', {id: "@id", type: "@type"}, {
      query: { method: 'GET', params: {type: 'people'}, isArray: true },
    });
  }).
  
  factory('errorHandler', function() {
    var errorHandler = {};
    errorHandler.message = function(message) {
      console.log("ERROR: " + message)
    };
    return errorHandler;
  }).

  factory('currentDate', function() {
    return {
      get: function() {
        return new Date();
      }
    };
  }).

  factory('commonPeopleCtrl', function(Person, errorHandler) {
    var commonPeopleCtrl = {}
    
    commonPeopleCtrl.include = function($scope, type, id) {

      // Query people based on passed parameters
      $scope.people = [];
      if (type) {
        Person.get(
          { id: id, type: type },
          function(result) {
            $scope.people = [result];
          }, 
          function() {
            $scope.people = [];
            errorHandler.message('This profile could not be found');
          }
        );
      }
      else {
        $scope.people = Person.query();
      }


      // List of fields for each type
      $scope.date_field_list = function(person) {
        return (person.type == 'students') ? ["birthday"] : [];
      }
      
      $scope.field_list = function(person) {
        var list = [
          "mobile",
          "home_phone",
          "office_phone",
          "email",
          "additional_emails",
          "address",
          "notes"
        ];
        if (person.type == 'students') {
          list.unshift("blood_group");
        }
        return list;
      };
    };

    return commonPeopleCtrl
  });
