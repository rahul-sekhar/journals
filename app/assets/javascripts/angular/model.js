'use strict';

angular.module('journals.model', ['journals.ajax', 'journals.model.associations']).

  factory('model', ['ajax', '$rootScope', '$q', function (ajax, $rootScope, $q) {

    return function (name, path, options) {
      var defaults = {
        extensions: [],
        saveFields: ['name'],
        hasParent: false
      }
      options = angular.extend(defaults, options);
      var model = {};

      /*------ reader for the path ---------*/

      model.getPath = function () {
        return path;
      };

      /* ----- Function to create an instance ---- */

      model.create = function (inputData) {
        var instance = {};

        // Insert default data if present
        angular.extend(instance, options.defaultData);

        // Get instance data to be saved
        instance.getSaveData = function () {
          var data = {};

          // Run extension beforeSave functions
          angular.forEach(options.extensions, function (extension) {
            if (extension.beforeSave) extension.beforeSave(instance);
          });

          // Select only required fields
          angular.forEach(options.saveFields, function (field) {
            data[field] = instance[field];
          });

          return data;
        };

        // Format data to be sent to the server
        instance.formatHttpData = function (data) {
          var outData = {};
          outData[name] = data;
          return outData
        };

        instance.url = function () {
          var url = path;

          if (instance.id) {
            url += '/' + instance.id
          }

          if (options.hasParent) {
            if (!instance._parent) {
              throw new Error('_parent model not present');
            }
            else {
              if (instance._parent.isNew()) {
                throw new Error('_parent model not saved');
              }
              else {
                url = instance._parent.url() + url;
              }
            }
          }
          return url;
        };

        instance.isNew = function() {
          return !instance.id;
        };

        // Load data into the model
        instance.load = function (data) {
          angular.forEach(data, function (value, key) {
            if (!angular.isFunction(value)) {
              instance[key] = value;
            }
          });

          // Call extensions
          angular.forEach(options.extensions, function (extension) {
            extension(instance);
          });
        };

        // Save instance
        instance.save = function () {
          var data, method;
          data = instance.getSaveData();
          if (instance.isNew()) {
            method = 'POST';
          } else {
            method = 'PUT';
          }

          return ajax({ url: instance.url(), method: method, data: instance.formatHttpData(data) }).
            then(function (response) {
              instance.load(response.data);
              return instance;
            }, function (response) {
              if (instance.isNew()) {
                instance.delete();
              }
              return $q.reject(response);
            });
        };


        // Update a field
        instance.updateField = function (field, value) {
          var oldVal, data = {};

          oldVal = instance[field];
          instance[field] = value;

          if (instance.isNew()) {
            if (!value) {
              instance.delete();
              return $q.reject();
            }
            else {
              return instance.save();
            }
          }
          else {
            if (oldVal == value) {
              return $q.when(instance);
            }

            data[field] = instance.getSaveData()[field];
            return ajax({ url: instance.url(), method: 'PUT', data: instance.formatHttpData(data) }).
              then(function (response) {
                instance.load(response.data);
                return instance;
              },
              function (response) {
                instance[field] = oldVal;
                return $q.reject(response);
              });
          }
        }


        // Delete function
        instance.delete = function () {
          instance.deleted = true;

          if (instance.isNew()) {
            return $q.when(instance);
          } else {
            return ajax({ url: instance.url(), method: 'DELETE' }).
              then(function () {
                return instance;
              }, function (response) {
                delete instance.deleted;
                return $q.reject(response);
              });
          }
        };

        // Call extension setup functions
          angular.forEach(options.extensions, function (extension) {
            if (extension.setup) extension.setup(instance);
          });

        // Initial load
        instance.load(inputData);

        return instance;
      };

      return model
    }
  }]);