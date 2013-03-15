'use strict';

angular.module('journals.model', ['journals.ajax', 'journals.helpers']).

  factory('model', ['ajax', '$rootScope', function (ajax, $rootScope) {

    return function (name, path, options) {
      var defaults = {
        extensions: [],
        saveFields: ['name']
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

        // Format data to be sent to the server
        instance.formatHttpData = function () {
          var outData = {};
          outData[name] = {};

          // Send only required fields
          angular.forEach(options.saveFields, function (field) {
            outData[name][field] = instance[field];
          });

          return outData;
        };

        instance.url = function () {
          return path + '/' + instance.id;
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
          if (instance.id) {
            ajax({ url: instance.url(), method: 'PUT', data: instance.formatHttpData() }).
              then(function (response) {
                instance.load(response.data);
              });
          }
          else {
            ajax({ url: path, method: 'POST', data: instance.formatHttpData() }).
              then(function (response) {
                instance.load(response.data);
              }, function () {
                instance.delete();
              });
          }
        };


        // Update a field
        instance.updateField = function (field, value) {
          var oldVal = instance[field];
          instance[field] = value;

          if (instance.id) {
            if (oldVal == value) return;

            var data = {};
            data[field] = value;
            ajax({ url: instance.url(), method: 'PUT', data: instance.formatHttpData() }).
              then(function (response) {
                instance.load(response.data);
              },
              function () {
                instance[field] = oldVal;
              });
          }
          else {
            if (!value) {
              instance.delete();
            }
            else {
              instance.save();
            }
          }
        }


        // Delete function
        instance.delete = function () {
          instance.deleted = true;

          if (instance.id) {
            ajax({ url: instance.url(), method: 'DELETE' }).
              then(null, function (response) {
                delete instance.deleted;
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
  }]).


  /*------------ model association extension -------------*/

  factory('association', ['arrayHelper', 'ajax', '$injector', function (arrayHelper, ajax, $injector) {
    return function (targetString, name, options) {
      var defaults = {
        loaded: false,
        mirror: false
      };
      options = angular.extend(defaults, options);

      var assocName = name + 's';
      var idsName = name + '_ids';
      var capitalizedName = name.substring(0, 1).toUpperCase() + name.substring(1);
      if (options.mirror) {
        var mirrorName = options.mirror.substring(0, 1).toUpperCase() + options.mirror.substring(1);
      }

      var association = function (instance) {
        var targetCollection = $injector.get(targetString);

        // For preloaded objects
        if (options.loaded) {
          if (instance[assocName]) {
            instance[assocName] = instance[assocName].map(targetCollection.update);
          }
        }

        // For objects that need to be loaded
        else {
          var assocs = [];

          if (instance[idsName]) {
            angular.forEach(instance[idsName], function (id) {
              targetCollection.get(id).then(function (match) {
                assocs.push(match);
              });
            });
          }

          instance[assocName] = assocs;
        }
      };

      association.setup = function (instance) {
        var targetCollection = $injector.get(targetString);

        // Remaining instances
        var remaining = []
        instance['remaining' + capitalizedName + 's'] = function () {
          var diff = arrayHelper.difference(targetCollection.all(), instance[assocName])
          arrayHelper.shallowCopy(diff, remaining);
          return remaining;
        };

        // Create new instance
        instance['new' + capitalizedName] = function (data) {
          data = angular.extend({ _parent: instance }, data)
          var newAssoc = targetCollection.add(data);
          instance[assocName].unshift(newAssoc);
          return newAssoc;
        };

        // Add instance
        instance['add' + capitalizedName] = function (target, local) {
          instance[assocName].push(target);
          if (local) return;

          ajax({ url: instance.url() + '/' + assocName + '/' + target.id, method: 'POST' }).
            then(function () {
              if (options.mirror) target['add' + mirrorName](instance, true);
            },
            function (response) {
              arrayHelper.removeItem(instance[assocName], target);
            });
        };

        // Remove instance
         instance['remove' + capitalizedName] = function (target, local) {
          arrayHelper.removeItem(instance[assocName], target);
          if(local) return;

          ajax({ url: instance.url() + '/' + assocName + '/' + target.id, method: 'DELETE'}).
            then(function () {
              if (target.parent_count) {
                target.parent_count -= 1;
              }
              if (options.mirror) target['remove' + mirrorName](instance, true);
            },
            function (response) {
              instance[assocName].push(target);
            });
        };
      };

      return association;
    };
  }]);