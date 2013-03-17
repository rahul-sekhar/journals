'use strict';

angular.module('journals.people.models', ['journals.model', 'journals.collection', 'journals.groups',
  'journals.ajax', 'journals.people.guardianExtensions']).

  /*---- Students collection -----*/

  factory('Students', ['model', 'collection', 'association', 'resetPasswordExtension', 'archiveExtension',
    function (model, collection, association, resetPasswordExtension, archiveExtension) {

      var studentModel = model('student', '/students', {
        extensions: [
          association('Guardians', 'guardian', { loaded: true }),
          association('Groups', 'group'),
          association('Teachers', 'mentor', { mirror: 'mentee' }),
          resetPasswordExtension(),
          archiveExtension()
        ],
        saveFields: ['full_name', 'email', 'mobile', 'home_phone', 'office_phone',
          'address', 'blood_group', 'birthday', 'additional_emails', 'notes'],
        defaultData: { type: 'Student' }
      });

      return collection(studentModel, { url: '/students/all' });
    }]).


  /*---- Teachers collection -----*/

  factory('Teachers', ['model', 'collection', 'association', 'resetPasswordExtension',
    'archiveExtension',
    function (model, collection, association, resetPasswordExtension, archiveExtension) {

      var teacherModel = model('teacher', '/teachers', {
        extensions: [
          association('Students', 'mentee', { mirror: 'mentor' }),
          resetPasswordExtension(),
          archiveExtension()
        ],
        saveFields: ['full_name', 'email', 'mobile', 'home_phone', 'office_phone',
          'address', 'additional_emails', 'notes'],
          defaultData: { type: 'Teacher' }
      });

      return collection(teacherModel, { url: '/teachers/all' });
    }]).


  /*---- Guardians collection -----*/

  factory('Guardians', ['model', 'collection', 'resetPasswordExtension','guardianExtension',
    function (model, collection, resetPasswordExtension, guardianExtension) {

      var guardianModel = model('guardian', '/guardians', {
        extensions: [
          resetPasswordExtension(),
          guardianExtension()
        ],
        saveFields: ['full_name', 'email', 'mobile', 'home_phone', 'office_phone',
          'address', 'additional_emails', 'notes'],
          defaultData: { type: 'Guardian' }
      });

      return collection(guardianModel, { url: '/guardians/all' });
    }]).

  /*---------- People interface ------------*/

  factory('peopleInterface', ['ajax', 'Teachers', 'Students', function (ajax, Teachers, Students) {
    var peopleInterface = {};

    peopleInterface.load = function (url) {
      return ajax({ url: url }).
        then(function (response) {
          var people, metadata;

          people = response.data.items.map(function (person) {
            switch (person.type) {
            case 'Teacher':
              return Teachers.update(person);
            case 'Student':
              return Students.update(person);
            default:
              throw new Error('Invalid type for person');
            }
          });

          metadata = response.data;
          delete metadata.items;

          return { metadata: metadata, people: people };
        });
    };

    peopleInterface.loadProfile = function (url) {
      return ajax({ url: url }).
        then(function (response) {
          var people, person;
          person = response.data;

          switch (person.type) {
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

    peopleInterface.addTeacher = function(data) {
      return Teachers.add(data);
    };

    peopleInterface.addStudent = function(data) {
      return Students.add(data);
    };

    return peopleInterface;
  }]).

  /*---- Profile administration extensions -----*/

  factory('resetPasswordExtension', ['ajax', function (ajax) {
    return function () {
      var resetPasswordExtension = function () {};

      resetPasswordExtension.setup =  function (instance) {
        instance.resetPassword = function () {
          var old = instance.active;
          instance.active = true;

          ajax({
            url: instance.url() + '/reset',
            method: 'POST',
            notification: 'An email has been sent to ' + instance.email + ' with a randomly generated password.'
          }).then(null, function () {
            instance.active = old;
          });
        };
      };

      return resetPasswordExtension;
    };
  }]).

  factory('archiveExtension', ['ajax', function (ajax) {
    return function () {
      var archiveExtension = function () {};

      archiveExtension.setup =  function (instance) {
        instance.toggleArchive = function () {
          var message;

          instance.archived = !instance.archived;
          if (instance.archived) {
            message = instance.full_name + ' has been archived and can no longer login.';
          } else {
            message = instance.full_name + ' is no longer archived, but must be activated to be able to login.';
          }

          ajax({
            url: instance.url() + '/archive',
            method: 'POST',
            notification: message
          }).then(null, function () {
            instance.archived = !instance.archived;
          });
        };
      };

      return archiveExtension;
    };
  }]);