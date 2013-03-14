'use strict';

angular.module('journals.collection', ['journals.model', 'journals.ajax']).
  
  factory('collection', ['ajax', '$timeout', '$q',
    function(ajax, $timeout, $q) {

    return function(model, options) {
      var defaults = {
        reloadInterval: 30000,
        url: model.getPath()
      }
      options = angular.extend(defaults, options);

      var collectionObj = {}, collection = [], promise;
      
      // Initial query to load the complete collection
      var query = function() {
        promise = ajax({url: options.url, method: 'GET'}).
          
          then(function(response) {
            response.data.map(collectionObj.update);
          },

          function() {
            $timeout(function() {
              promise = null;
            }, options.reloadInterval);
          });
      };

      var find = function(id) {
        var match = collection.filter(function(x) {
          return (x.id == id);
        })[0];

        if (match) return match;
        return false;
      };


      // Updates an instance of the collection
      collectionObj.update = function(data) {
        if (!data.id) throw new Error('Object has no ID');

        var match = find(data.id);
        if (match) {
          match.load(data);
          return match;
        }
        else {
          var newInstance = model.create(data);
          collection.push(newInstance);
          return newInstance;
        }
      };


      // Returns a reference to the entire collection
      collectionObj.all = function() {
        if (!promise) query();
        return collection;
      };


      // Returns a promise, which resolves with a single instance by ID
      collectionObj.get = function(id) {
        if (!promise) query();
        
        return promise.then(function() {
          var match = find(id)

          if (match) return match;
          return $q.reject('Instance not found');
        });
      };

      // Adds a new instance
      collectionObj.add = function() {
        var newInstance = model.create()
        collection.unshift(newInstance);
        return newInstance;
      };

      return collectionObj;
    };
  }]);