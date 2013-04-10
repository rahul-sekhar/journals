'use strict';

angular.module('journals.tags', ['journals.collection', 'journals.model']).

  factory('Tags', ['collection', 'model',
    function (collection, model) {
      var tagModel = model('tag', '/tags');

      return collection(tagModel, { reload: true });
    }]);