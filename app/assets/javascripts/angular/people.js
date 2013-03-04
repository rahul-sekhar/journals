'use strict';

angular.module('journals.people', ['journals.messageHandler', 'journals.assets', 'journals.currentDate']).
  

  /*------- People Controller ----------*/
  
  controller('PeopleCtrl', ['$scope', '$route', '$routeParams', '$location', 'PeopleInterface', 'messageHandler',
      function($scope, $route, $routeParams, $location, PeopleInterface, messageHandler) {
    
    var loadPeople;
    var id = $routeParams.id;

    // For a single person
    if (id) {
      $scope.singlePerson = true;
      $scope.pageTitle = 'Profile';

      loadPeople = function() {
        PeopleInterface.get($location.url()).
          then(function(result) {
            if (result.person.type === 'Guardian') {
              // Set the people to the guardians students
              $scope.people = result.person.students;
            }
            else {
              $scope.people = [result.person];  
            }
            
            $scope.pageTitle = 'Profile: ' + result.person.full_name;
          }, function(message) {
            messageHandler.showError(message);
            $scope.pageTitle = 'Profile not found';
          });
      };
    }

    // For pages of people
    else {
      $scope.filterName = $route.current.filterName;
      $scope.singlePerson = false;
      $scope.pageTitle = 'People';

      loadPeople = function() {
        PeopleInterface.query($location.url()).
          then(function(result) {
            $scope.people = result.people;
            $scope.currentPage = result.metadata.currentPage;
            $scope.totalPages = result.metadata.totalPages;
          }, function(message) {
            messageHandler.showError(message);
          });
      };

      $scope.doSearch = function(val) {
        $location.search('search', val).replace();
      };
    }

    // Handle changes in route params
    $scope.$on("$routeUpdate", function() {
      loadPeople();
    });

    // Initial load
    loadPeople();
  }]).


  /*------- Person Model ----------*/

  factory('Person', ['$http', 'messageHandler', function($http, messageHandler) {
    var Person = {};

    // Create a person instance
    Person.create = function(inputData) {
      var person = {};
      // Extend the instance with the input data
      angular.extend(person, inputData);

      // Check the input type
      if (['Student', 'Teacher', 'Guardian'].indexOf(person.type) === -1) {
        throw new Error('Invalid type for person');
      }

      // Convert guardians if the person is a student
      if(person.type === 'Student' && person.guardians) {
        person.guardians = Person.createFromArray(person.guardians);
      }

      // Convert students if the person is a guardian
      if(person.type === 'Guardian' && person.students) {
        person.students = Person.createFromArray(person.students);
      }

      // Set the persons fields based on the type
      var fields = [
        {name: "Mobile", slug: "mobile"},
        {name: "Home Phone", slug: "home_phone"},
        {name: "Office Phone", slug: "office_phone"},
        {name: "Email", slug: "email"},
        {name: "Additional Emails", slug: "additional_emails"},
        {name: "Address", slug: "address", type: "textarea", filter: "multiline"},
        {name: "Notes", slug: "notes", type: "textarea", filter: "multiline"}
      ];
      if (person.type === 'Student') {
        fields.unshift(
          {name: "Birthday", slug: "formatted_birthday", type: "date", filter: "dateWithAge"},
          {name: "Blood Group", slug: "blood_group"}
        );
      }
      fields = fields.map(function(obj) {
        if (!obj.type) obj.type = 'text';
        return obj;
      });
      person.fields = fields;

      // Function to get the url for the person
      person.url = function() {
        if (!person.id) {
          throw new Error('Invalid id for person');
        }
        return '/' + person.type.toLowerCase() + 's/' + person.id;
      };

      // Update a field for the person
      person.update = function(field_name, value) {
        var old_val = person[field_name];
        if (old_val == value) return;
        person[field_name] = value;

        var params = {};
        var personData = params[person.type.toLowerCase()] = {};
        personData[field_name] = value;

        $http.put(person.url(), params).
          then(function(response) {
            person[field_name] = response.data[field_name];
          },
          function(response) {
            person[field_name] = old_val;
            messageHandler.showError(response);
          });
      };

      return person;
    };

    // Create an array of person instances
    Person.createFromArray = function(array) {
      return array.map(Person.create);
    };

    return Person;
  }]).


  /*------- People Interface ----------*/

  factory('PeopleInterface', ['$q', '$http', 'Person', function($q, $http, Person) {
    var PeopleInterface = {};

    PeopleInterface.query = function(url) {
      var deferred = $q.defer();
      $http.get(url).
        then(function(response) {
          var result = {};
          result.people = Person.createFromArray(response.data.items);
          result.metadata = response.data;
          delete result.metadata.items;
          deferred.resolve(result);
        }, 
        function(response) {
          deferred.reject(response);
        });
      return deferred.promise;
    };

    PeopleInterface.get = function(url) {
      var deferred = $q.defer();
      $http.get(url).
        then(function(response) {
          var result = {};
          result.person = Person.create(response.data);
          deferred.resolve(result);
        }, 
        function(response) {
          deferred.reject(response);
        });
      return deferred.promise;
    };

    return PeopleInterface;
  }]).


  /* -------------------- Profile fields directive ----------------------- */

  directive('profileFields', ['assets', function(assets) {
    return {
      restrict: 'E',
      transclude: true,
      scope: { 
        person: '=parent'
      },
      templateUrl: assets.url('profile_fields_template.html'),
      replace: true
    };
  }]).


  /* ---------------------- Date with age filter ---------------------*/

  filter('dateWithAge', function(currentDate) {
    return function(date_text) {
      if (!date_text) return null;

      var birthDate = $.datepicker.parseDate('dd-mm-yy', date_text);
      var currDate = currentDate.get();

      var age = currDate.getFullYear() - birthDate.getFullYear();
      var m = currDate.getMonth() - birthDate.getMonth();
      if (m < 0 || (m === 0 && currDate.getDate() < birthDate.getDate())) {
        age--;
      }
      return date_text + ' (' + age + ' yrs)';
    };
  });

