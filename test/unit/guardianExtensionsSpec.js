'use strict';

describe('guardian extensions module', function () {
  beforeEach(module('journals.people.guardianExtensions'));

  /*------------------ Guardian extension ---------------------*/

  describe('guardianExtension', function () {
    var extension, instance, httpBackend, checkDuplicateGuardians, rootScope, Guardians;

    beforeEach(module(function ($provide) {
      checkDuplicateGuardians = jasmine.createSpy();
      $provide.value('checkDuplicateGuardians', checkDuplicateGuardians);
    }));

    beforeEach(inject(function (guardianExtension, $httpBackend, $rootScope, _Guardians_) {
      Guardians = _Guardians_;
      httpBackend = $httpBackend;
      rootScope = $rootScope;
      extension = guardianExtension();
      instance = {};
    }));

    it('is a blank function', function () {
      extension(instance);
      expect(instance).toEqual({});
    });

    describe('setup()', function () {
      var oldSave, deferred;

      beforeEach(inject(function ($q) {
        oldSave = instance.save = jasmine.createSpy();
        deferred = $q.defer();
        checkDuplicateGuardians.andReturn(deferred.promise);
        extension.setup(instance);
      }));

      describe('save()', function () {
        describe('with an id', function () {
          beforeEach(function () {
            instance.id = 5;
            instance.save();
          });

          it('calls the old save function', function () {
            expect(oldSave).toHaveBeenCalled();
          });
        });

        describe('without an id', function () {
          beforeEach(function () {
            instance.save();
          });

          it('calls checkDuplicateGuardians', function () {
            expect(checkDuplicateGuardians).toHaveBeenCalledWith(instance);
          });

          it('does not call the old save function', function () {
            expect(oldSave).not.toHaveBeenCalled();
          });

          describe('if the promise is rejected', function () {
            beforeEach(function () {
              instance.delete = jasmine.createSpy();
              deferred.reject();
              rootScope.$apply();
            });

            it('deletes the instance', function () {
              expect(instance.delete).toHaveBeenCalled();
            });
          });

          describe('if the promise is resolved with 0', function () {
            describe('on success', function () {
              beforeEach(function () {
                httpBackend.expectPOST('/students/3/guardians.json', 'some data').respond(200, 'data');
                instance._parent = { id: 3 };
                instance.formatHttpData = function () { return 'some data' };
                deferred.resolve(0);
                rootScope.$apply();
              });

              it('sends a message to the server', function () {
                httpBackend.verifyNoOutstandingExpectation();
              });

              it('loads recieved data into the instance', function () {
                instance.load = jasmine.createSpy();
                httpBackend.flush();
                expect(instance.load).toHaveBeenCalledWith('data');
              });
            });

            describe('on failure', function () {
              beforeEach(function () {
                httpBackend.expectPOST('/students/3/guardians.json', 'some data').respond(400);
                instance._parent = { id: 3 };
                instance.formatHttpData = function () { return 'some data' };
                instance.delete = jasmine.createSpy();
                deferred.resolve(0);
                rootScope.$apply();
                httpBackend.flush();
              });

              it('deletes the instance', function () {
                expect(instance.delete).toHaveBeenCalled();
              });
            });
          });

          describe('if the promise is resolved with a number', function () {
            var newInstance;

            beforeEach(function () {
              httpBackend.expectPOST('/students/3/guardians.json', { guardian_id: 1 }).respond(200, 'data');

              newInstance = { data: 'val' };
              spyOn(Guardians, 'update').andReturn(newInstance);

              instance._parent = { id: 3, guardians: [1, instance, 3] };
              instance.formatHttpData = function () { return 'some data' };

              deferred.resolve(1);
              rootScope.$apply();
            });

            it('sends a message to the server', function () {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('updates Guardians with recieved data', function () {
              httpBackend.flush();
              expect(Guardians.update).toHaveBeenCalledWith('data');
            });

            it('switches the instance in the parent object', function() {
              httpBackend.flush();
              expect(instance._parent.guardians).toEqualData([1, { data: 'val' }, 3])
            });
          });
        });
      });
    });
  });


  /*--------------- Service to check for duplicate guardians --------------*/
  describe('checkDuplicateGuardians', function () {
    var promise, success, error, scope, guardian, student, httpBackend, checkDuplicateGuardians;

    beforeEach(inject(function ($rootScope, _checkDuplicateGuardians_, $httpBackend) {
      checkDuplicateGuardians = _checkDuplicateGuardians_;
      scope = $rootScope.$new();
      checkDuplicateGuardians.registerScope(scope);

      httpBackend = $httpBackend;

      student = { id: 5, name: 'Student name', url: function () { return '/students/5' }};
      guardian = { _parent: student, full_name: 'Guardian name' };

      success = jasmine.createSpy();
      error = jasmine.createSpy();
    }));

    describe('with an error response', function () {
      beforeEach(function () {
        httpBackend.expectGET('/students/5/guardians/check_duplicates.json?name=Guardian+name').respond(400);
        promise = checkDuplicateGuardians(guardian);
        promise.then(success, error);
      });

      it('sends a request to the server', function() {
        httpBackend.verifyNoOutstandingExpectation();
      });

      it('rejects the promise', function() {
        httpBackend.flush();
        expect(error).toHaveBeenCalled();
      });
    });

    describe('with an empty response', function() {
      beforeEach(function () {
        httpBackend.expectGET('/students/5/guardians/check_duplicates.json?name=Guardian+name').respond([]);
        promise = checkDuplicateGuardians(guardian);
        promise.then(success, error);
        httpBackend.flush();
      });

      it('resolves the promise with false', function() {
        expect(success).toHaveBeenCalledWith(0);
      });
    });

    describe('with a response containing duplicates', function() {
      var deferred;

      beforeEach(inject(function ($q) {
        deferred = $q.defer();

        httpBackend.expectGET('/students/5/guardians/check_duplicates.json?name=Guardian+name').
          respond([{id: 5, students: 'sam'}, {id: 7, students: 'tim and tom'}]);
        promise = checkDuplicateGuardians(guardian);
        promise.then(success, error);
        scope.show = jasmine.createSpy().andReturn(deferred.promise);
        httpBackend.flush();
      }));

      it('sets the scope duplicates', function() {
        expect(scope.duplicates).toEqual([{id: 5, students: 'sam'}, {id: 7, students: 'tim and tom'}]);
      });

      it('sets the scope guardian name', function() {
        expect(scope.guardianName).toEqual('Guardian name');
      });

      it('sets the scope student name', function() {
        expect(scope.studentName).toEqual('Student name');
      });

      it('calls the scope show function', function() {
        expect(scope.show).toHaveBeenCalled();
      });

      it('is resolved by the show function promise', function() {
        deferred.resolve('some val');
        scope.$apply()
        expect(success).toHaveBeenCalledWith('some val');
      });

      it('is rejected when the show function promise is rejected', function() {
        deferred.reject();
        scope.$apply()
        expect(error).toHaveBeenCalled();
      });
    });
  });


  /*--------------- Controller for duplicate guardian modal ------------------*/
  describe('duplicateGuardiansCtrl', function () {
    var scope, checkDuplicateGuardians;

    beforeEach(inject(function ($rootScope, $controller, _checkDuplicateGuardians_) {
      checkDuplicateGuardians = _checkDuplicateGuardians_;
      spyOn(checkDuplicateGuardians, 'registerScope');

      scope = $rootScope.$new();
      $controller('DuplicateGuardiansCtrl', { $scope: scope });
    }));

    it('registers the scope with the duplicate guardian service', function () {
      expect(checkDuplicateGuardians.registerScope).toHaveBeenCalledWith(scope);
    });

    it('sets guardianDialog.shown to false', function () {
      expect(scope.guardianDialog.shown).toEqual(false);
    });

    it('sets duplicates to an empty array', function () {
      expect(scope.duplicates).toEqual([]);
    });

    it('sets guardianName to null', function () {
      expect(scope.guardianName).toBeNull();
    });

    it('sets studentName to null', function () {
      expect(scope.studentName).toBeNull();
    });

    it('sets response to an object', function () {
      expect(scope.response).toEqual({});
    });

    describe('show()', function() {
      var promise, success, error;

      beforeEach(function() {
        success = jasmine.createSpy();
        error = jasmine.createSpy();
        promise = scope.show();
        promise.then(success, error);
      });

      it('sets show to true', function() {
        expect(scope.guardianDialog.shown).toEqual(true);
      });

      it('sets the response value to 0', function() {
        expect(scope.response.value).toEqual(0)
      });

      it('does not immediately resolve the scope', function() {
        scope.$apply();
        expect(success).not.toHaveBeenCalled();
        expect(error).not.toHaveBeenCalled();
      });

      describe('if guardianDialog.shown is set to false', function() {
        beforeEach(function() {
          scope.guardianDialog.shown = false;
          scope.$apply();
        });

        it('rejects the promise', function() {
          expect(error).toHaveBeenCalled();
          expect(success).not.toHaveBeenCalled();
        });

        it('calls a different callback if called again subsequently', function() {
          error.reset();
          var otherError = jasmine.createSpy();
          scope.show().then(null, otherError);
          scope.$apply();
          scope.guardianDialog.shown = false;
          scope.$apply();
          expect(error).not.toHaveBeenCalled();
          expect(otherError).toHaveBeenCalled();
        });
      });

      describe('if submit is called', function() {
        beforeEach(function() {
          scope.submit('67');
          scope.$apply();
        });

        it('resolves the promise with the passed value, parsed to an integer', function() {
          expect(success).toHaveBeenCalledWith(67);
          expect(error).not.toHaveBeenCalled();
        });

        it('does not subsequently reject the promise', function() {
          scope.cancel();
          scope.$apply();
          expect(error).not.toHaveBeenCalled();
        });

        it('calls a different callback if called again subsequently', function() {
          error.reset();
          var otherSuccess = jasmine.createSpy();
          success.reset();
          scope.show().then(otherSuccess);
          scope.$apply();
          scope.submit(52)
          scope.$apply();
          expect(success).not.toHaveBeenCalled();
          expect(otherSuccess).toHaveBeenCalledWith(52);
        });
      });
    });

    describe('scope.cancel', function() {
      it('sets guardianDialog.shown to false', function() {
        scope.guardianDialog.shown = true;
        scope.cancel();
        expect(scope.guardianDialog.shown).toEqual(false);
      });
    });

    describe('allStudents()', function () {
      it('returns nothing when duplicates is empty', function () {
        scope.duplicates = [];
        expect(scope.allStudents()).toEqual('');
      });

      it('returns the joined values of the duplicates students', function () {
        scope.duplicates = [{id: 1, students: 'blah and gah'}, {id: 2, students: 'hmm'}, {id: 3, students: 'huh'}];
        expect(scope.allStudents()).toEqual('blah and gah or hmm or huh');
      });

      it('returns a single value for a single duplicate', function () {
        scope.duplicates = [{id: 1, students: 'blah and gah'}];
        expect(scope.allStudents()).toEqual('blah and gah');
      });
    });
  });
});