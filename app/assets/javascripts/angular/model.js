'use strict';

angular.module('journals.model', ['journals.ajax']).
  
  factory('model', ['ajax', function(ajax) {

    return function(name, path, options) {
      var defaults = {
        extensions: []
      }
      options = angular.extend(defaults, options);
      var model = {};

      /*------ reader for the path ---------*/

      model.getPath = function() {
        return path;
      };

      /* ----- Function to create an instance ---- */

      model.create = function(inputData) {
        var instance = {};

        var url = function() {
          return path + '/' + instance.id;
        };

        var formatHttpData = function(inData) {
          var outData = {};
          outData[name] = inData;

          // Call extensions
          angular.forEach(options.extensions, function(extension) {
            if(extension.formatHttpData) extension.formatHttpData(outData[name]);
          });

          if (outData[name].id) delete outData[name].id;
          return outData;
        };

        var load = function(data) {
          angular.extend(instance, data);

          // Call extensions
          angular.forEach(options.extensions, function(extension) {
            extension(instance);
          });
        };

        // Save instance
        instance.save = function() {
          if (instance.id) {
            ajax({ url: url(), method: 'PUT', data: formatHttpData(instance) }).
              then(function(response) {
                load(response.data);
              });
          }
          else {
            ajax({ url: path, method: 'POST', data: formatHttpData(instance) }).
              then(function(response) {
                load(response.data);
              }, function() {
                instance.delete();
              });
          }
        };


        // Update a field
        instance.updateField = function(field, value) {
          var oldVal = instance[field];
          instance[field] = value;

          if (instance.id) {
            if (oldVal == value) return;

            var data = {};
            data[field] = value;
            ajax({ url: url(), method: 'PUT', data: formatHttpData(data) }).
              then(function(response) {
                load(response.data);
              },
              function() {
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
        instance.delete = function() {
          instance.deleted = true;

          if (instance.id) {
            ajax({ url: url(), method: 'DELETE' }).
              then(null, function(response) {
                delete instance.deleted;
              });
          }
        };

        // Initial load
        load(inputData);

        return instance;
      };

      return model
    }
  }]).
  
  /*---- extension to allow for editable fields for a model -----*/
  factory('editableFieldsExtension', function() {
    return function(primaryField) {
      var extension = function(model) {
        model.editing = {};

        // Set the primary field for a new model
        if (primaryField && !model.id) {
          model.editing[primaryField] = true;
        }
      };

      extension.formatHttpData = function(data) {
        delete data.editing;
      };

      return extension;
    };
  });