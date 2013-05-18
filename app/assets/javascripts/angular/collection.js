'use strict';

angular.module('journals.collection', ['journals.model', 'journals.ajax']).

  factory('collection', ['ajax', '$timeout', '$q',
    function (ajax, $timeout, $q) {
      return function (model, options) {
        var defaults, collectionObj = {}, collection = [], promise, queryFn, findFn;

        defaults = {
          reloadInterval: 30000,
          url: model.getPath(),
          reload: false
        };
        options = angular.extend(defaults, options);

        // Initial query to load the complete collection
        queryFn = function () {
          promise = ajax({url: options.url, method: 'GET'}).

            then(function (response) {
              response.data.map(collectionObj.update);
            }, function () {
              $timeout(function () {
                promise = null;
              }, options.reloadInterval);
            });
        };

        findFn = function (id) {
          var match = collection.filter(function (x) {
            return (x.id === id);
          })[0];

          if (match) {
            return match;
          }
          return false;
        };


        // Updates an instance of the collection
        collectionObj.update = function (data) {
          var match, newInstance;

          if (!data.id) {
            throw new Error('Object has no ID');
          }

          match = findFn(data.id);
          if (match) {
            match.load(data);
            return match;
          }

          newInstance = model.create(data);
          collection.push(newInstance);
          return newInstance;
        };


        // Returns a reference to the entire collection
        collectionObj.all = function () {
          if (!promise || options.reload) {
            queryFn();
          }
          return collection;
        };


        // Returns a promise, which resolves with a single instance by ID
        collectionObj.get = function (id) {
          if (!promise) {
            queryFn();
          }

          return promise.then(function () {
            var match = findFn(id);

            if (match) {
              return match;
            }
            return $q.reject('Instance not found');
          });
        };

        // Adds a new instance
        collectionObj.add = function (data, addToEnd) {
          var newInstance = model.create(data);
          if (addToEnd) {
            collection.push(newInstance);
          } else {
            collection.unshift(newInstance);
          }
          return newInstance;
        };

        return collectionObj;
      };
    }]);