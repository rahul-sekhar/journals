'use strict';

angular.module('journals.posts.models', ['journals.model', 'journals.collection', 'journals.people.models']).

  /*----------------- Post model --------------------*/

  factory('Posts', ['model', 'collection', 'association', 'singleAssociation', 'postExtension',
    function (model, collection, association, singleAssociation, postExtension) {

      var postModel = model('post', '/posts', {
        extensions: [
          singleAssociation('author_type', 'author', {
            polymorphic: function(type) {
              return type + 's';
            }
          }),
          association('Students', 'student'),
          association('Teachers', 'teacher'),
          association('Comments', 'comment', {loaded: true, addToEnd: true}),
          association('StudentObservations', 'student_observation', {loaded: true}),
          postExtension()
        ],
        saveFields: ['title', 'content', 'tag_names', 'teacher_ids', 'student_ids',
          'visible_to_guardians', 'visible_to_students', 'student_observations_attributes']
      });

      return collection(postModel);
    }]).

  factory('Comments', ['model', 'collection', 'singleAssociation',
    function (model, collection, singleAssociation) {

      var commentModel = model('comment', '/comments', {
        extensions: [
          singleAssociation('author_type', 'author', {
            polymorphic: function(type) {
              return type + 's';
            }
          })
        ],
        hasParent: true,
        saveFields: ['content']
      });

      return collection(commentModel);
    }]).

  factory('StudentObservations', ['model', 'collection', 'singleAssociation',
    function (model, collection, singleAssociation) {

      var studentObservationModel = model('student_observation', null, {
        extensions: [
          singleAssociation('Students', 'student'),
        ]
      });

      return collection(studentObservationModel);
    }]).

  factory('postExtension', [function () {
    return function () {
      var postExtension = function (instance) {
        instance.observationContent = {};
        instance.observationId = {};

        angular.forEach(instance.student_observations, function (observation) {
          instance.observationContent[observation.student_id] = observation.content;
          instance.observationId[observation.student_id] = observation.id;
        });
      };

      postExtension.setup = function (instance) {
        instance.restrictions = function () {
          var restrictions = []
          if (instance.visible_to_students === false) {
            restrictions.push('students');
          }
          if (instance.visible_to_guardians === false) {
            restrictions.push('guardians');
          }

          if (restrictions.length) {
            return 'Not visible to ' + restrictions.join(' or ');
          }
          else {
            return null;
          }
        }
      };

      postExtension.beforeSave = function (instance) {
        instance.student_observations_attributes = [];

        angular.forEach(instance.observationContent, function (value, key) {
          if (!key) {
            return;
          }

          var observation = {
            student_id: parseInt(key, 10),
            content: value
          };
          if (instance.observationId[key]) {
            observation.id = instance.observationId[key];
          }

          instance.student_observations_attributes.push(observation);
        });
      };

      return postExtension;
    }
  }]);