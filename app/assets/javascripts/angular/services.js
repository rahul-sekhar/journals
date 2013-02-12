'use strict';

/* Services */

angular.module('journalsApp.services', ['ngResource']).

  factory('Person', function($resource) {
    return $resource('/:type/:id', {id: "@id", type: "@type"}, {
      query: { method: 'GET', params: {type: 'people'}, isArray: true },
      query_archived: { method: 'GET', params: {type: 'people', id: 'archived'}, isArray: true }
    });
  }).
  
  factory('errorHandler', function() {
    var errorHandler = {};
    
    errorHandler.message = function(message) {
      console.log("ERROR: " + message);
    };

    errorHandler.raise_404 = function() {
      this.message("Page not found");
    }
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
      if (type == 'students' || type == 'teachers') {
        
        // For a single profile
        if (id) {
          Person.get(
            { id: id, type: type },

            // Success - load the profile
            function(result) {
              $scope.people = [result];
            },

            // Failure - profile not found 
            function() {
              $scope.people = [];
              errorHandler.message('This profile could not be found');
            }
          );
        }

        // List of students or teachers
        else {
          $scope.people = Person.query({ type: type });
        }
      }

      // Get a guardian
      else if(type == 'guardians') {
        if (id) {
          Person.query(
            { id: id, type: type },

            // Success - load the profile array
            function(result) {
              $scope.people = result
            },

            // Failure - profile not found 
            function() {
              $scope.people = [];
              errorHandler.message('This profile could not be found');
            }
          );
        }

        // Raise a 404 error if a guardian list is requested
        else {
          $scope.people = [];
          errorHandler.raise_404();
        }
      }

      // List of archived students/teachers
      else if(type == 'archived') {
        $scope.people = Person.query_archived();
      }

      // List of all students and teachers
      else {
        $scope.people = Person.query();
      }


      // List of fields for each type
      $scope.dateFieldList = function(person) {
        return (person.type == 'students') ? ["birthday"] : [];
      }
      
      $scope.fieldList = function(person) {
        var list = [
          "mobile",
          "home_phone",
          "office_phone",
          "email",
          "additional_emails",
        ];
        if (person.type == 'students') {
          list.unshift("blood_group");
        }
        return list;
      };

      $scope.multiLineFieldList = function(person) {
        return ["address", "notes"];
      }
    };

    return commonPeopleCtrl
  });
