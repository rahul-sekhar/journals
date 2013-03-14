'use strict';

angular.module('journals.collection', ['journals.model', 'journals.ajax', 'journals.helpers']).
  
  factory('collection', ['ajax', 'arrayHelper', '$timeout', '$q',
    function(ajax, arrayHelper, $timeout, $q) {

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
            var instances = response.data.map(model.create);
            arrayHelper.shallowCopy(instances, collection);
          },

          function() {
            $timeout(function() {
              promise = null;
            }, options.reloadInterval);
          });
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
          var instance = collection.filter(function(x) {
            return (x.id == id);
          })[0];

          if (instance) {
            return instance;
          }
          else {
            return $q.reject('Instance not found');
          }
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