'use strict';

angular.module('journals.people.guardianExtensions', ['journals.ajax', 'journals.people.models', 'journals.helpers']).

  /*--------- Guardian extension ---------------*/

  factory('guardianExtension', ['ajax', 'checkDuplicateGuardians', '$injector', 'arrayHelper',
    function (ajax, checkDuplicateGuardians, $injector, arrayHelper) {
      return function () {
        var guardianExtension = function () {};

        guardianExtension.setup =  function (instance) {
          var oldSaveFn = instance.save;

          instance.save = function () {
            if (instance.id) {
              oldSaveFn();
            }
            else {
              checkDuplicateGuardians(instance).
                then(function (duplicateId) {
                  var data;

                  if (duplicateId === 0) {
                    // Create a new guardian
                    data = instance.formatHttpData()
                  } else {
                    // Use an existing guardian
                    data = { guardian_id: duplicateId }
                  }

                  ajax({
                    url: '/students/' + instance._parent.id + '/guardians',
                    method: 'POST',
                    data: data
                  }).then(function (response) {
                    if (duplicateId === 0) {
                      instance.load(response.data);
                    } else {
                      var newInstance, Guardians;
                      Guardians = $injector.get('Guardians');
                      newInstance = Guardians.update(response.data);
                      arrayHelper.replace(instance._parent.guardians, instance, newInstance);
                    }

                  }, function () {
                    instance.delete();
                  });
                }, function () {
                  instance.delete();
                });

            }
          };
        };

        return guardianExtension;
      };
    }]).

  /*-------------- Service to check for duplicate guardians --------------*/

  factory('checkDuplicateGuardians', ['ajax', '$q', function (ajax, $q) {
    var scope, checkDuplicateGuardians;

    checkDuplicateGuardians = function (guardian) {
      return ajax({
        url: guardian._parent.url() + '/guardians/check_duplicates',
        params: { name: guardian.name }

      }).then(function(response) {

        if (response.data.length === 0) {
          // Empty array
          return 0;

        } else if (response.data.length > 0) {
          scope.duplicates = response.data;
          scope.guardianName = guardian.name;
          scope.studentName = guardian._parent.short_name;
          return scope.show();

        } else {
          // Unknown response
          return $q.reject();

        }
      });
    };

    checkDuplicateGuardians.registerScope = function(recievedScope) {
      scope = recievedScope;
    }

    return checkDuplicateGuardians;
  }]).

  /*--------------- controller for duplicate guardians modal -------------*/

  controller('DuplicateGuardiansCtrl', ['$scope', 'checkDuplicateGuardians', '$q',
    function($scope, checkDuplicateGuardians, $q) {
      $scope.guardianDialog = { shown: false };
      $scope.duplicates = [];
      $scope.studentName = null;
      $scope.guardianName = null;
      $scope.response = {};

      var deferred;

      $scope.show = function() {
        $scope.guardianDialog.shown = true;
        $scope.response.value = 0;

        deferred = $q.defer();
        return deferred.promise;
      };

      $scope.submit = function(value) {
        if (deferred) {
          deferred.resolve(parseInt(value, 10));
          deferred = null;
        }
        $scope.guardianDialog.shown = false;
      };


      $scope.cancel = function() {
        $scope.guardianDialog.shown = false;
      };

      $scope.$watch('guardianDialog.shown', function(value) {
        if (!value) {
          if (deferred) {
            deferred.reject();
            deferred = null;
          }
        }
      });

      $scope.allStudents = function() {
        var duplicate_students = $scope.duplicates.map(function(object) {
          return object.students;
        });
        return duplicate_students.join(' or ');
      };

      checkDuplicateGuardians.registerScope($scope);

    }]);