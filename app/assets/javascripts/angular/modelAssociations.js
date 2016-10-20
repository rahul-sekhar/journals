angular.module('journals.model.associations', ['journals.ajax', 'journals.helpers']).

  /*------------ model association extensions -------------*/

  factory('singleAssociation', ['ajax', '$injector', function (ajax, $injector) {
    return function (targetString, name, options) {
      var defaults = {
        loaded: false,
        polymorphic: false
      };
      options = angular.extend(defaults, options);

      var assocName = name;
      var idsName = name + '_id';
      var capitalizedName = name.substring(0, 1).toUpperCase() + name.substring(1);

      var singleAssociation = function (instance) {
        var targetCollection, tmpTargetString;

        // Load the association collection from an attribute if polymorphic is set
        if (options.polymorphic) {
          if (!instance[targetString]) {
            return;
          }
          tmpTargetString = options.polymorphic(instance[targetString]);
          targetCollection = $injector.get(tmpTargetString);
        }
        else {
          targetCollection = $injector.get(targetString);
        }

        // For preloaded objects
        if (options.loaded) {
          if (instance[assocName]) {
            instance[assocName] = targetCollection.update(instance[assocName]);
          }
        }

        // For objects that need to be loaded
        else {
          if (instance[idsName]) {
            targetCollection.get(instance[idsName]).then(function (match) {
              instance[assocName] = match;
            });
          }
        }
      };

      singleAssociation.beforeSave = function (instance) {
        var object = instance[assocName];

        if (object && object.id) {
          instance[idsName] = object.id
        } else if (instance[idsName]) {
          delete instance[idsName];
        }
      };

      return singleAssociation;
    };
  }]).

  factory('association', ['arrayHelper', 'ajax', '$injector', function (arrayHelper, ajax, $injector) {
    return function (targetString, name, options) {
      var defaults = {
        loaded: false,
        mirror: false,
        addToEnd: false
      };
      options = angular.extend(defaults, options);

      var assocName = name + 's';
      var idsName = name + '_ids';
      var camelCasedName = name.replace(/(_[a-z])/g, function($1){return $1.toUpperCase().replace('_','');});
      var capitalizedName = camelCasedName.substring(0, 1).toUpperCase() + camelCasedName.substring(1);
      if (options.mirror) {
        var mirrorName = options.mirror.substring(0, 1).toUpperCase() + options.mirror.substring(1);
      }

      var association = function (instance) {
        var targetCollection = $injector.get(targetString);

        // For preloaded objects
        if (options.loaded) {
          if (instance[assocName]) {
            instance[assocName] = instance[assocName].filter(function (assocObj) {
              return !assocObj.deleted;
            }).map(function (assocObj) {
              assocObj = targetCollection.update(assocObj);
              assocObj._parent = instance;
              return assocObj;
            });
          }
        }

        // For objects that need to be loaded
        else {
          var assocs = [];

          if (instance[idsName]) {
            angular.forEach(instance[idsName], function (id) {
              targetCollection.get(id).then(function (match) {
                match._parent = instance;
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
          diff = diff.filter(function (object) {
            return !object.deleted;
          });
          arrayHelper.shallowCopy(diff, remaining);
          return remaining;
        };

        // Create new instance
        instance['new' + capitalizedName] = function (data) {
          data = angular.extend({ _parent: instance }, data)
          var newAssoc = targetCollection.add(data);

          if (options.addToEnd) {
            instance[assocName].push(newAssoc);
          } else {
            instance[assocName].unshift(newAssoc);
          }

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

      association.beforeSave = function (instance) {
        instance[idsName] = [];

        angular.forEach(instance[assocName], function (object) {
          if (object.id) {
            instance[idsName].push(object.id);
          }
        });
      };

      return association;
    };
  }]);