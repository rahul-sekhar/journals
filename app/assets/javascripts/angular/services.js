'use strict';

/* Services */

angular.module('journalsApp.services', ['ngResource', 'journalsApp.filters']).

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

  factory('commonPeopleCtrl', function(Person, errorHandler, capitalizeFilter) {
    var commonPeopleCtrl = {}
    
    commonPeopleCtrl.include = function($scope, type, id) {

      // Query people based on passed parameters
      $scope.people = [];
      if (type == 'students' || type == 'teachers') {

        // For a single profile
        if (id) {
          $scope.pageTitle = 'Profile';
          Person.get(
            { id: id, type: type },

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

        // List of students or teachers
        else {
          $scope.pageTitle = capitalizeFilter(type);
          $scope.people = Person.query({ type: type });
        }
      }

      // Get a guardian
      else if(type == 'guardians') {
        if (id) {
          $scope.pageTitle = 'Profile';
          Person.get(
            { id: id, type: type },

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

        // Raise a 404 error if a guardian list is requested
        else {
          $scope.people = [];
          errorHandler.raise_404();
        }
      }

      // List of archived students/teachers
      else if(type == 'archived') {
        $scope.pageTitle = 'Archived people';
        $scope.people = Person.query_archived();
      }

      // List of all students and teachers
      else {
        $scope.pageTitle = 'People';
        $scope.people = Person.query();
      }


      // Broadcast an event to add a field
      $scope.addField = function(person, field) {
        $scope.$broadcast("addField", person, field)
      };

      // List of fields for each type
      $scope.dateFieldList = function(person) {
        return (person.type == 'students') ? ["birthday"] : [];
      };
      
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
      };

      // List of fields that are empty
      $scope.remainingFields = function(person) {

        // Handle date fields first
        var fields = $scope.dateFieldList(person).filter(function(element) {
          return !person['formatted_' + element];
        });

        // Handle other fields
        fields = fields.concat($scope.fieldList(person)).concat($scope.multiLineFieldList(person));

        return fields.filter(function(element) {
          return !person[element];
        });
      };
    };

    return commonPeopleCtrl
  });
