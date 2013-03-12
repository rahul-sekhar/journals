angular.module('journals.cachedCollection', ['journals.arrayHelper', 'journals.messageHandler']).
  
  factory('cachedCollection', ['$http', '$timeout', '$q', 'arrayHelper', 'messageHandler', 
    function($http, $timeout, $q, arrayHelper, messageHandler) {

    return function(url, objectName, callback, reload_interval) {
      if (!reload_interval) reload_interval = 30000;
      if (!callback) callback = angular.identity;

      var collectionObj = {};
      var collection = [];
      var promise;

      collectionObj.collection = collection;

      var query = function() {
        promise = $http.get(url).
          then(function(response) {
            arrayHelper.shallowCopy(response.data.map(callback), collection);
          }, function(response) {
            arrayHelper.shallowCopy([], collection);
            messageHandler.showError(response, 'Information about ' + objectName + 's could not be loaded.');

            // Set an interval for the next try
            $timeout(function() {
              promise = undefined;
            }, reload_interval);
          });
      };

      collectionObj.all = function() {
        if (!promise) query();
        return collection;
      };

      // Function to get a group by ID
      collectionObj.get = function(id) {
        if (!promise) query();
        return promise.
          then(function() {
            var item = collection.filter(function(obj) {
              return obj.id == id;
            })[0];

            if (item) {
              return item;
            }
            else {
              return $q.reject('The requested ' + objectName + ' could not be found.');
            }
          });
      };

      return collectionObj;
    };
  }]);