'use strict';

angular.module('journals.people', ['journals.messageHandler', 'journals.assets', 'journals.currentDate', 
  'journals.groups', 'journals.helpers', 'journals.cachedCollection']).
  

  /*------- People Controller ----------*/
  
  controller('PeopleCtrl', ['$scope', '$route', '$routeParams', '$location', 'PeopleInterface', 
      'Groups', 'messageHandler', '$window', 'arrayHelper', 'Person', '$http',
      function($scope, $route, $routeParams, $location, PeopleInterface, Groups, messageHandler, $window, arrayHelper, Person, $http) {
    
    var loadPeople;
    var id = $routeParams.id;
    $scope.pageData = $route.current.pageData;
    var isGroup = $scope.pageData.isGroup;

    // For a single person
    if (id && !isGroup) {
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
          }, function() {
            $scope.pageTitle = 'Profile not found';
          });
      };
    }

    // For pages of people
    else {
      $scope.singlePerson = false;
      $scope.pageTitle = 'People';
      $scope.groups = Groups.all();

      if (isGroup) {
        Groups.get(id).
          then(function(group) {
            $scope.pageData.filter = group.name;
          }, function(message) {
            messageHandler.showError(null, message);
          });
      }

      loadPeople = function() {
        PeopleInterface.query($location.url()).
          then(function(result) {
            $scope.people = result.people;
            $scope.currentPage = result.metadata.current_page;
            $scope.totalPages = result.metadata.total_pages;
          });
      };

      $scope.doSearch = function(val) {
        $location.search('search', val).replace();
      };
    }

    // Delete people
    $scope.delete = function(person) {
      var conf = $window.confirm("Are you sure you want to delete the profile for '" + person.full_name + "'?" +
        "Anything that has been created by that person will be lost. You can archive the profile if you don't want to lose data.");
      if (!conf) return;

      var promise = person.delete();
      
      if ($scope.singlePerson) {
        promise.then(function() {
          var remaining = $scope.people.filter(function(obj) {
            return !obj.deleted;
          });
          
          // Redirect if there are no remaining people
          if (!remaining.length) {
            $location.url('/people');
            messageHandler.notifyOnRouteChange(person.full_name + ' has been deleted.');
          }
        });
      }
    };

    var addPerson = function(type) {
      var newPerson = {type: type};
      newPerson.editing = {full_name: true};

      var remove = function() {
        arrayHelper.removeItem($scope.people, newPerson);
      };
      
      newPerson.update = function(field_name, value) {
        if (field_name != 'full_name') throw new Error('Can only update the name for a newly created person');

        // Replace the function with a blank function so as to prevent subsequent calls
        newPerson.update = function() {};
        
        // Remove if a blank value is passed
        if (!value) {
          remove();
          return;
        }

        var params = {};
        var personData = params[newPerson.type.toLowerCase()] = {full_name: value};

        $http.post('/' + newPerson.type.toLowerCase() + 's', params).
          then(function(response) {
            var index = $scope.people.indexOf(newPerson);
            $scope.people[index] = response.data
            newPerson[field_name] = Person.create(response.data);
          },
          function(response) {
            remove();
            messageHandler.showError(response, 'An error occured while creating ' + newPerson.full_name + '.');
          });
      };

      $scope.people.unshift(newPerson);
    };

    // Add people
    $scope.addTeacher = function() {
      addPerson('Teacher');
    };

    // Handle changes in route params
    $scope.$on("$routeUpdate", function() {
      loadPeople();
    });

    // Initial load
    loadPeople();
  }]).


  /*------- Person Model ----------*/

  factory('Person', ['$http', 'messageHandler', 'Groups', 'arrayHelper', '$q', '$window', 'Students', 'Teachers',
    function($http, messageHandler, Groups, arrayHelper, $q, $window, Students, Teachers) {

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

      // Convert contained guardians
      if (person.guardians) {
        person.guardians = Person.createFromArray(person.guardians);
      }

      // Convert contained students
      if (person.students) {
        person.students = Person.createFromArray(person.students);
      }

      if (person.type == 'Student') {
        /* Handle group associations */
        person.groups = [];
        if (person.group_ids) {
          person.group_ids.forEach(function(id) {
            Groups.get(id).then(function(group) {
              person.groups.push(group);
            });
          });
        }

        // Remaining groups
        var remaining_groups = [];
        person.remainingGroups = function() {
          var diff = arrayHelper.difference(Groups.all(), person.groups)
          arrayHelper.shallowCopy(diff, remaining_groups);
          return remaining_groups;
        };

        // Add group
        person.addGroup = function(group) {
          person.groups.push(group);
          $http.post(person.url() + '/add_group', { group_id: group.id }).
            then(null, function(response) {
              messageHandler.showError(response, 'Group could not be added.');
              arrayHelper.removeItem(person.groups, group);
            });
        };

        // Remove group
        person.removeGroup = function(group) {
          arrayHelper.removeItem(person.groups, group);
          $http.post(person.url() + '/remove_group', { group_id: group.id }).
            then(null, function(response) {
              messageHandler.showError(response, 'Group could not be removed.');
              person.groups.push(group);
            });
        };


        /* Handle mentor associations */
        person.mentors = [];
        if (person.mentor_ids) {
          person.mentor_ids.forEach(function(id) {
            Teachers.get(id).then(function(mentor) {
              person.mentors.push(mentor);
            });
          });
        }

        // Remaining mentors
        var remaining_mentors = [];
        person.remainingMentors = function() {
          var diff = arrayHelper.difference(Teachers.all(), person.mentors)
          arrayHelper.shallowCopy(diff, remaining_mentors);
          return remaining_mentors;
        };

        // Add mentor
        person.addMentor = function(mentor) {
          person.mentors.push(mentor);
          $http.post(person.url() + '/add_mentor', { teacher_id: mentor.id }).
            then(null, function(response) {
              messageHandler.showError(response, 'Mentor could not be added.');
              arrayHelper.removeItem(person.mentors, mentor);
            });
        };

        // Remove mentor
        person.removeMentor = function(mentor) {
          arrayHelper.removeItem(person.mentors, mentor);
          $http.post(person.url() + '/remove_mentor', { teacher_id: mentor.id }).
            then(null, function(response) {
              messageHandler.showError(response, 'Mentor could not be removed.');
              person.mentors.push(mentor);
            });
        };
      }

      if (person.type == 'Teacher') {
        /* Handle mentee associations */
        person.mentees = [];
        if (person.mentee_ids) {
          person.mentee_ids.forEach(function(id) {
            Students.get(id).then(function(mentee) {
              person.mentees.push(mentee);
            });
          });
        }

        // Remaining mentees
        var remaining_mentees = [];
        person.remainingMentees = function() {
          var diff = arrayHelper.difference(Students.all(), person.mentees)
          arrayHelper.shallowCopy(diff, remaining_mentees);
          return remaining_mentees;
        };

        // Add mentee
        person.addMentee = function(mentee) {
          person.mentees.push(mentee);
          $http.post(person.url() + '/add_mentee', { student_id: mentee.id }).
            then(null, function(response) {
              messageHandler.showError(response, 'Mentee could not be added.');
              arrayHelper.removeItem(person.mentees, mentee);
            });
        };

        // Remove mentee
        person.removeMentee = function(mentee) {
          arrayHelper.removeItem(person.mentees, mentee);
          $http.post(person.url() + '/remove_mentee', { student_id: mentee.id }).
            then(null, function(response) {
              messageHandler.showError(response, 'Mentee could not be removed.');
              person.mentees.push(mentee);
            });
        };
      }
      

      // Set a blank editing object
      person.editing = {};

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

      // Check which fields are blank
      person.remainingFields = function() {
        return person.fields.filter(function(field) {
          return !person[field.slug];
        });
      };

      // Add a field (set it's editing value to true)
      person.addField = function(field_name) {
        person.editing[field_name] = true;
      };

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
            messageHandler.showError(response, 'An error occured while updating ' + person.full_name + '.');
          });
      };

      // Delete the person
      person.delete = function() {
        person.deleted = true;
        return $http.delete(person.url()).
          then(null, function(response) {
            delete person.deleted;
            messageHandler.showError(response, 'An error occured while deleting ' + person.full_name + '.');
            return $q.reject();
          });
      };

      // Delete a guardian
      person.removeGuardian = function(guardian) {
        if (person.type != 'Student') throw new Error('Can only delete guardians for a student');

        if (guardian.number_of_students <= 1) {
          var conf = $window.confirm("Are you sure you want to delete the guardian '" + guardian.full_name + "'?" +
        "Anything that has been created by that person will be lost.");
          if (!conf) return;
        }
        
        guardian.deleted = true;
        guardian.number_of_students--;
        $http.delete(person.url() + guardian.url()).
          then(null, function(response) {
            delete guardian.deleted;
            guardian.number_of_students++;
            messageHandler.showError(response, 'An error occured while removing ' + guardian.full_name + '.');
          });
      };

      // Reset password
      person.resetPassword = function() {
        var action = person.active ? 'reset the password for' : 'activate';
        var conf = $window.confirm("Are you sure you want to " + action + " '" + person.full_name +
          "? A randomly generated password will be emailed to " + person.email + ".");
        if (!conf) return;

        var old = person.active;
        person.active = true;
        $http.post(person.url() + '/reset').
          then(function() {
            messageHandler.showNotification('An email has been sent to ' + person.email + ' with a randomly generated password.')
          }, 
          function(response) {
            person.active = old;
            messageHandler.showError(response, 'Could not ' + action + ' ' + person.full_name + '.');
          });
      };

      person.toggleArchive = function() {
        if (!person.archived) {
          var conf = $window.confirm("Are you sure you want to archive '" + person.full_name +
            "? Created data will remain but the user will not be able to log in.");
          if (!conf) return;
        }

        person.archived = !person.archived;
        $http.post(person.url() + '/archive').
          then(function() {
            if (person.archived) {
              messageHandler.showNotification(person.full_name + ' has been archived and can no longer login.');
            }
            else {
              messageHandler.showNotification(person.full_name + ' is no longer archived, but must be activated to be able to login.');
            }
            
          },
          function(response) {
            person.archived = !person.archived;
            messageHandler.showError(response, 'Could not ' + (person.archived ? 'archive ' : 'unarchive ') + person.full_name + '.');
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

  factory('PeopleInterface', ['$q', '$http', 'Person', 'messageHandler', function($q, $http, Person, messageHandler) {

    var PeopleInterface = {};

    var query_with_promise = function(url, successFn) {
      var deferred = $q.defer();
      $http.get(url).
        then(function(response) {
          deferred.resolve(response.data);
        }, 
        function(response) {
          deferred.reject(response);
          messageHandler.showError(response, 'Profiles could not be loaded.');
        });
      return deferred.promise;
    };

    PeopleInterface.query = function(url) {
      return query_with_promise(url).
        then(function(data) {
          var result = {};
          result.people = Person.createFromArray(data.items);
          result.metadata = data;
          delete result.metadata.items;
          return result;
        });
    };

    PeopleInterface.get = function(url) {
      return query_with_promise(url).
        then(function(data) {
          var result = {};
          result.person = Person.create(data);
          return result;
        });
    };

    return PeopleInterface;
  }]).

  /* Teachers */

  factory('Teachers', ['cachedCollection', function(cachedCollection) {
    var Teachers = {};
    var teachersCollection = cachedCollection('/teachers/all', 'teachers');
    Teachers.all = teachersCollection.all;
    Teachers.get = teachersCollection.get;
    return Teachers;
  }]).

  /* Students */

  factory('Students', ['cachedCollection', function(cachedCollection) {
    var Students = {};
    var studentsCollection = cachedCollection('/students/all', 'students');
    Students.all = studentsCollection.all;
    Students.get = studentsCollection.get;
    return Students;
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

  filter('dateWithAge', ['currentDate', function(currentDate) {
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
  }]);

