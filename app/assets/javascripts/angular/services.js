'use strict';

/* Services */

angular.module('journalsApp.services', ['ngResource', 'journalsApp.filters']).

  factory('Person', function($resource) {
    return $resource('/:type/:id', {id: "@id", type: "@type"}, {
      query: { method: 'GET', params: {type: 'people'} },
      query_students: { method: 'GET', params: {type: 'students'} },
      query_teachers: { method: 'GET', params: {type: 'teachers'} },
      query_archived: { method: 'GET', params: {type: 'people', id: 'archived'} }
    });
  }).

  factory('PeopleCtrlBase', function($location) {
    var PeopleCtrlBase = {};
    PeopleCtrlBase.include = function(scope, query_function) {
      var reloadPeople = function() {
        var params = {};
        if ($location.search().page) params.page = $location.search().page;
        if ($location.search().search) params.search = $location.search().search;
        
        query_function(params,
          // Success
          function(result) {
            scope.people = result.items;
            scope.currentPage = result.current_page;
            scope.totalPages = result.total_pages;
          }
        );
      };

      // Initial query
      reloadPeople();

      scope.doSearch = function() {
        $location.search('search', scope.search).replace();
      }

      scope.$on("$routeUpdate", function() {
        reloadPeople();
      });
    };
    return PeopleCtrlBase;
  }).
  
  factory('dialogHandler', function() {
    var dialogHandler = {};
    
    dialogHandler.message = function(message) {
      console.log("ERROR: " + message);
    };

    return dialogHandler;
  }).

  factory('currentDate', function() {
    return {
      get: function() {
        return new Date();
      }
    };
  }).

  factory('profileFields', function() {
    var profileFields = {}
    
    profileFields.date = {
      students: ["birthday"],
      teachers: [],
      guardians: []
    }

    var standard = ["mobile", "home_phone", "office_phone", "email", "additional_emails"];
    profileFields.standard = {
      students: ["blood_group"].concat(standard),
      teachers: standard,
      guardians: standard
    }

    var multiLine = ["address", "notes"];
    profileFields.multiLine = {
      students: multiLine,
      teachers: multiLine,
      guardians: multiLine
    }

    return profileFields
  });
