'use strict';

angular.module('journals.posts.models', ['journals.model', 'journals.collection', 'journals.people.models']).

  /*----------------- Post model --------------------*/

  factory('Posts', ['model', 'collection', 'association', 'singleAssociation',
    function (model, collection, association, singleAssociation) {

      var postModel = model('post', '/posts', {
        extensions: [
          singleAssociation('author_type', 'author', {
            polymorphic: function(type) {
              return type + 's';
            }
          }),
          association('Students', 'student'),
          association('Teachers', 'teacher')
        ],
        saveFields: ['title', 'content', 'tag_names', 'teacher_ids', 'student_ids',
          'visible_to_guardians', 'visible_to_students', 'student_observations_attributes'],
      });

      return collection(postModel);
    }]);