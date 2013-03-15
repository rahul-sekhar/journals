'use strict';

angular.module('journals.people', ['journals.model', 'journals.collection', 'journals.groups', 
  'journals.ajax', 'journals.assets', 'journals.currentDate']).
  
  /*---- Students collection -----*/

  factory('Students', ['model', 'collection', 'editableFieldsExtension', 'Guardians', 'association',
    function(model, collection, editableFieldsExtension, Guardians, association, Groups, Teachers) {

    var studentModel = model('student', '/students', {
      extensions: [
        association('Guardians', 'guardian', { loaded: true }),
        association('Groups', 'group'),
        association('Teachers', 'mentor', { mirror: 'mentee' }),
        editableFieldsExtension('full_name')
      ],
      saveFields: ['full_name', 'email', 'mobile', 'home_phone', 'office_phone',
        'address', 'blood_group', 'formatted_birthday', 'additional_emails', 'notes']
    });

    return collection(studentModel, { url: '/students/all' });
  }]).


  /*---- Teachers collection -----*/

  factory('Teachers', ['model', 'collection', 'editableFieldsExtension', 'association',
    function(model, collection, editableFieldsExtension, association) {

    var teacherModel = model('teacher', '/teachers', {
      extensions: [
        association('Students', 'mentee', { mirror: 'mentor' }),
        editableFieldsExtension('full_name')
      ],
      saveFields: ['full_name', 'email', 'mobile', 'home_phone', 'office_phone',
        'address', 'additional_emails', 'notes']
    });

    return collection(teacherModel, { url: '/teachers/all' });
  }]).


  /*---- Guardians collection -----*/

  factory('Guardians', ['model', 'collection', 'editableFieldsExtension', 
    function(model, collection, editableFieldsExtension) {

    var guardianModel = model('guardian', '/guardians', {
      extensions: [editableFieldsExtension('full_name')],
      saveFields: ['full_name', 'email', 'mobile', 'home_phone', 'office_phone',
        'address', 'additional_emails', 'notes']
    });

    return collection(guardianModel);
  }]).

  /*---------- People interface ------------*/

  factory('peopleInterface', ['ajax', 'Teachers', 'Students', function(ajax, Teachers, Students) {
    var peopleInterface = {};

    peopleInterface.load = function(url) {
      return ajax({ url: url, method: 'GET' }).
        then(function(response) {
          var people = response.data.items.map(function(person) {
            switch(person.type) {
              case 'Teacher':
                return Teachers.update(person);
              case 'Student':
                return Students.update(person);
              default:
                throw new Error('Invalid type for person');
            }
          });

          var metadata = response.data;
          delete metadata.items;

          return { metadata: metadata, people: people };
        });
    };

    peopleInterface.loadProfile = function(url) {
      return ajax({ url: url, method: 'GET' }).
        then(function(response) {
          var person = response.data;
          var people;

          switch(person.type) {
            case 'Teacher':
              people = [Teachers.update(person)];
              break;
            case 'Student':
              people = [Students.update(person)];
              break;
            case 'Guardian':
              people = person.students.map(Students.update);
              break;
            default:
              throw new Error('Invalid type for person');
          }

          return { name: person.full_name, people: people };
        });
    };

    return peopleInterface;
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
      replace: true,
      controller: 'profileFieldsCtrl'
    };
  }]).

  controller('profileFieldsCtrl', ['$scope', function($scope) {
    $scope.fields = [];

    $scope.$watch('person.type', function(type) {
      var fields = [
        {name: "Mobile", slug: "mobile"},
        {name: "Home Phone", slug: "home_phone"},
        {name: "Office Phone", slug: "office_phone"},
        {name: "Email", slug: "email"},
        {name: "Additional Emails", slug: "additional_emails"},
        {name: "Address", slug: "address", type: "textarea", filter: "multiline"},
        {name: "Notes", slug: "notes", type: "textarea", filter: "multiline"}
      ];
      if (type === 'Student') {
        fields.unshift(
          {name: "Birthday", slug: "formatted_birthday", type: "date", filter: "dateWithAge"},
          {name: "Blood Group", slug: "blood_group"}
        );
      }
      fields = fields.map(function(obj) {
        if (!obj.type) obj.type = 'text';
        return obj;
      });
      $scope.fields = fields;
    });

    $scope.hasRemainingFields = function() {
      for ( var i = 0; i < $scope.fields.length; i++ ) {
        // Return true if any field is empty
        if (!$scope.person[$scope.fields[i].slug]) return true;
      }
      return false;
    };

    $scope.addField = function(field) {
      $scope.person.editing[field] = true;
    }
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