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
          postExtension()
        ],
        saveFields: ['title', 'content', 'tag_names', 'teacher_ids', 'student_ids',
          'visible_to_guardians', 'visible_to_students', 'student_observations_attributes'],
      });

      return collection(postModel);
    }]).

  factory('postExtension', [function () {
    return function () {
      var postExtension = function () {};

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

      return postExtension;
    }
  }]);