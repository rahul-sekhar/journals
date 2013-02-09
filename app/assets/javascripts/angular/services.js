'use strict';

/* Services */

angular.module('journalsApp.services', ['ngResource']).
  factory('Person', function($resource) {
    return $resource('/:type/:personId', {personId: "@id", type: "@type"}, {
      query: { method: 'GET', params: {type: 'people'}, isArray: true },
      update: { method: 'PUT' }
    });
  });
