'use strict';

describe('people models module', function () {
  beforeEach(module('journals.people.models'));

  describe('Models with associations', function () {
    var collection, model, association, resetPasswordExtension, archiveExtension,
      guardianExtension;

    beforeEach(module(function ($provide) {
      model = jasmine.createSpy().andReturn('model');
      collection = jasmine.createSpy().andReturn('collection');

      association = jasmine.createSpy().andCallFake(function (arg1, name) {
        return name + ' association';
      });
      resetPasswordExtension = jasmine.createSpy().andReturn('resetPasswordExtension');
      archiveExtension = jasmine.createSpy().andReturn('archiveExtension');
      guardianExtension = jasmine.createSpy().andReturn('guardianExtension');

      $provide.value('model', model);
      $provide.value('collection', collection);
      $provide.value('association', association);
      $provide.value('resetPasswordExtension', resetPasswordExtension);
      $provide.value('archiveExtension', archiveExtension);
      $provide.value('guardianExtension', guardianExtension);
    }));


    /*------------------- Students collection -----------------------*/

    describe('Students', function () {
      var Students;

      beforeEach(inject(function (_Students_) {
        Students = _Students_;
      }));

      it('sets the model name to "student"', function () {
        expect(model.mostRecentCall.args[0]).toEqual('student');
      });

      it('sets the model url to "/students"', function () {
        expect(model.mostRecentCall.args[1]).toEqual('/students');
      });

      it('sets the extensions', function () {
        expect(model.mostRecentCall.args[2].extensions).toEqual([
          'guardian association',
          'group association',
          'mentor association',
          'resetPasswordExtension',
          'archiveExtension'
        ]);
      });

      it('sets the default data type', function () {
        expect(model.mostRecentCall.args[2].defaultData).toEqual({ type: 'Student' });
      });

      it('calls the collection with the model object', function () {
        expect(collection).toHaveBeenCalledWith('model', { url: '/students/all' });
      });

      it('returns the collection object', function () {
        expect(Students).toEqual('collection');
      });
    });


    /*------------------- Teachers collection -----------------------*/

    describe('Teachers', function () {
      var Teachers;

      beforeEach(inject(function (_Teachers_) {
        Teachers = _Teachers_;
      }));

      it('sets the model name to "teacher"', function () {
        expect(model.mostRecentCall.args[0]).toEqual('teacher');
      });

      it('sets the model url to "/teachers"', function () {
        expect(model.mostRecentCall.args[1]).toEqual('/teachers');
      });

      it('sets the extensions', function () {
        expect(model.mostRecentCall.args[2].extensions).toEqual([
          'mentee association',
          'resetPasswordExtension',
          'archiveExtension'
        ]);
      });

      it('sets the default data type', function () {
        expect(model.mostRecentCall.args[2].defaultData).toEqual({ type: 'Teacher' });
      });

      it('calls the collection with the model object', function () {
        expect(collection).toHaveBeenCalledWith('model', { url: '/teachers/all' });
      });

      it('returns the collection object', function () {
        expect(Teachers).toEqual('collection');
      });
    });


    /*------------------- Guardians collection -----------------------*/

    describe('Guardians', function () {
      var Guardians;

      beforeEach(inject(function (_Guardians_) {
        Guardians = _Guardians_;
      }));

      it('sets the model name to "guardian"', function () {
        expect(model.mostRecentCall.args[0]).toEqual('guardian');
      });

      it('sets the model url to "/guardians"', function () {
        expect(model.mostRecentCall.args[1]).toEqual('/guardians');
      });

      it('sets the extensions', function () {
        expect(model.mostRecentCall.args[2].extensions).toEqual([
          'resetPasswordExtension',
          'guardianExtension'
        ]);
      });

      it('sets the default data type', function () {
        expect(model.mostRecentCall.args[2].defaultData).toEqual({ type: 'Guardian' });
      });

      it('calls the collection with the model object', function () {
        expect(collection).toHaveBeenCalledWith('model', { url: '/guardians/all' });
      });

      it('returns the collection object', function () {
        expect(Guardians).toEqual('collection');
      });
    });
  });




  /*------------------- People interface ------------------------*/

  describe('peopleInterface', function () {
    var peopleInterface, httpBackend, promise, success, error, Teachers, Students;

    beforeEach(inject(function (_peopleInterface_, $httpBackend, _Teachers_, _Students_) {
      peopleInterface = _peopleInterface_
      httpBackend = $httpBackend;
      success = jasmine.createSpy();
      error = jasmine.createSpy();
      Teachers = _Teachers_;
      Students = _Students_;
      spyOn(Teachers, 'update').andReturn('teacher');
      spyOn(Students, 'update').andReturn('student');
    }));


    // Load collection

    describe('load()', function () {
      describe('for an invalid type', function () {
        beforeEach(function () {
          httpBackend.expectGET('/path.json').respond({
            items: [{id: 1, type: 'Something', name: "One"}, {id: 2, type: 'Teacher', name: "Two"}]
          });
          peopleInterface.load('/path');
        });

        it('throws an error', function () {
          expect(httpBackend.flush).toThrow('Invalid type for person');
        });
      });

      describe('on success', function () {
        beforeEach(function () {
          httpBackend.expectGET('/path.json').respond({
            data: 'value',
            other_data: 'other_value',
            items: [{id: 1, type: 'Student', name: "One"}, {id: 2, type: 'Teacher', name: "Two"}, {id: 3, type: 'Student'}]
          });
          promise = peopleInterface.load('/path');
          promise.then(success, error);
        });

        it('sends a request to the server', function () {
          httpBackend.verifyNoOutstandingExpectation();
        });

        it('does not immediately resolve the promise', function () {
          expect(success).not.toHaveBeenCalled();
          expect(error).not.toHaveBeenCalled();
        });

        describe('on response', function () {
          beforeEach(function () {
            httpBackend.flush();
          });

          it('resolves the promise', function () {
            expect(success).toHaveBeenCalled();
          });

          it('updates Teachers with each teacher', function () {
            expect(Teachers.update).toHaveBeenCalledWith({id: 2, type: 'Teacher', name: "Two"});
          });

          it('updates Students with each student', function () {
            expect(Students.update.callCount).toEqual(2);
            expect(Students.update.argsForCall[0]).toEqual([{id: 1, type: 'Student', name: "One"}]);
            expect(Students.update.argsForCall[1]).toEqual([{id: 3, type: 'Student'}]);
          });

          describe('the resolved data', function () {
            var response;

            beforeEach(function () {
              response = success.mostRecentCall.args[0];
            });

            it('contains the response metadata', function () {
              expect(response.metadata).toEqual({ data: 'value', other_data: 'other_value' });
            });

            it('contains the student and teacher instances', function () {
              expect(response.people).toEqual(['student', 'teacher', 'student']);
            });
          });
        });
      });

      describe('on failure', function () {
        beforeEach(function () {
          httpBackend.expectGET('/path.json').respond(400);
          promise = peopleInterface.load('/path');
          promise.then(success, error);
        });

        it('rejects the promise', function () {
          httpBackend.flush();
          expect(success).not.toHaveBeenCalled();
          expect(error).toHaveBeenCalled();
        });
      });
    });


    // Load profile

    describe('loadProfile()', function () {
      describe('for an invalid type', function () {
        beforeEach(function () {
          httpBackend.expectGET('/path.json').respond({ id: 1, type: 'Something', name: "One"});
          peopleInterface.loadProfile('/path');
        });

        it('throws an error', function () {
          expect(httpBackend.flush).toThrow('Invalid type for person');
        });
      });

      describe('on success', function () {
        describe('for a student', function () {
          beforeEach(function () {
            httpBackend.expectGET('/path.json').respond({id: 5, type: 'Student', name: 'Something', field: 'val'});
            promise = peopleInterface.loadProfile('/path');
            promise.then(success, error);
          });

          it('sends a request to the server', function () {
            httpBackend.verifyNoOutstandingExpectation();
          });

          it('does not immediately resolve the promise', function () {
            expect(success).not.toHaveBeenCalled();
            expect(error).not.toHaveBeenCalled();
          });

          describe('on response', function () {
            beforeEach(function () {
              httpBackend.flush();
            });

            it('resolves the promise', function () {
              expect(success).toHaveBeenCalled();
            });

            it('updates Students with the student', function () {
              expect(Students.update).toHaveBeenCalledWith({id: 5, type: 'Student', name: 'Something', field: 'val'});
            });

            describe('the resolved data', function () {
              var response;

              beforeEach(function () {
                response = success.mostRecentCall.args[0];
              });

              it('contains the student name', function () {
                expect(response.name).toEqual('Something');
              });

              it('contains the student instance', function () {
                expect(response.people).toEqual(['student']);
              });
            });
          });
        });

        describe('for a teacher', function () {
          beforeEach(function () {
            httpBackend.expectGET('/path.json').respond({id: 5, type: 'Teacher', name: 'Something', field: 'val'});
            promise = peopleInterface.loadProfile('/path');
            promise.then(success, error);
            httpBackend.flush();
          });

          it('updates Teachers with the teacher', function () {
            expect(Teachers.update).toHaveBeenCalledWith({id: 5, type: 'Teacher', name: 'Something', field: 'val'});
          });

          describe('the resolved data', function () {
            var response;

            beforeEach(function () {
              response = success.mostRecentCall.args[0];
            });

            it('contains the teacher name', function () {
              expect(response.name).toEqual('Something');
            });

            it('contains the teacher instance', function () {
              expect(response.people).toEqual(['teacher']);
            });
          });
        });

        describe('for a guardian', function () {
          beforeEach(function () {
            httpBackend.expectGET('/path.json').respond({
              id: 5,
              type: 'Guardian',
              name: 'Something',
              field: 'val',
              students: [
                {id: 3, name: 'Three', type: 'Student'},
                {id: 1, name: 'One', type: 'Student'}
              ]
            });
            promise = peopleInterface.loadProfile('/path');
            promise.then(success, error);
            httpBackend.flush();
          });

          it('updates Students with each student', function () {
            expect(Students.update.callCount).toEqual(2);
            expect(Students.update.argsForCall[0][0]).toEqual({id: 3, name: 'Three', type: 'Student'});
            expect(Students.update.argsForCall[1][0]).toEqual({id: 1, name: 'One', type: 'Student'});
          });

          describe('the resolved data', function () {
            var response;

            beforeEach(function () {
              response = success.mostRecentCall.args[0];
            });

            it('contains the guardian name', function () {
              expect(response.name).toEqual('Something');
            });

            it('contains the student instances', function () {
              expect(response.people).toEqual(['student', 'student']);
            });
          });
        });
      });

      describe('on failure', function () {
        beforeEach(function () {
          httpBackend.expectGET('/path.json').respond(400);
          promise = peopleInterface.loadProfile('/path');
          promise.then(success, error);
        });

        it('rejects the promise', function () {
          httpBackend.flush();
          expect(success).not.toHaveBeenCalled();
          expect(error).toHaveBeenCalled();
        });
      });
    });

    describe('addTeacher()', function () {
      var result;

      beforeEach(function () {
        spyOn(Teachers, 'add').andReturn('teacher');
        result = peopleInterface.addTeacher('some data');
      })

      it('calls the add function for the Teachers collection', function () {
        expect(Teachers.add).toHaveBeenCalledWith('some data');
      });

      it('returns the result', function () {
        expect(result).toEqual('teacher');
      });
    });

    describe('addStudent()', function () {
      var result;

      beforeEach(function () {
        spyOn(Students, 'add').andReturn('student');
        result = peopleInterface.addStudent('some data');
      })

      it('calls the add function for the Students collection', function () {
        expect(Students.add).toHaveBeenCalledWith('some data');
      });

      it('returns the result', function () {
        expect(result).toEqual('student');
      });
    });
  });


  /*------------- reset password extension --------------*/

  describe('resetPasswordExtension', function () {
    var extension, instance, httpBackend;

    beforeEach(inject(function (resetPasswordExtension, $httpBackend) {
      httpBackend = $httpBackend;
      extension = resetPasswordExtension();
      instance = {};
    }));

    it('is a blank function', function () {
      extension(instance);
      expect(instance).toEqual({});
    });

    describe('setup()', function () {
      beforeEach(function () {
        instance.url = function () { return '/objects/7' };
        extension.setup(instance);
      });

      describe('resetPassword()', function () {
        describe('on success', function () {
          beforeEach(function () {
            httpBackend.expectPOST('/objects/7/reset.json').respond(200);
            instance.resetPassword();
          });

          it('sends a message to the server', function () {
            httpBackend.verifyNoOutstandingExpectation();
          });

          it('sets the active value', function () {
            expect(instance.active).toEqual(true);
            httpBackend.flush();
            expect(instance.active).toEqual(true);
          });
        });

        describe('on failure', function () {
          beforeEach(function () {
            httpBackend.expectPOST('/objects/7/reset.json').respond(400);
            instance.resetPassword();
          });

          it('resets the active value', function () {
            httpBackend.flush();
            expect(instance.active).toBeUndefined();
          });
        });
      });
    });
  });


  /*------------- toggle archive extension --------------*/

  describe('archiveExtension', function () {
    var extension, instance, httpBackend;

    beforeEach(inject(function (archiveExtension, $httpBackend) {
      httpBackend = $httpBackend;
      extension = archiveExtension();
      instance = {};
    }));

    it('is a blank function', function () {
      extension(instance);
      expect(instance).toEqual({});
    });

    describe('setup()', function () {
      beforeEach(function () {
        instance.url = function () { return '/objects/7' };
        extension.setup(instance);
      });

      describe('toggleArchive()', function () {
        describe('on success', function () {
          beforeEach(function () {
            httpBackend.expectPOST('/objects/7/archive.json').respond(200);
            instance.toggleArchive();
          });

          it('sends a message to the server', function () {
            httpBackend.verifyNoOutstandingExpectation();
          });

          it('toggles the archived value', function () {
            expect(instance.archived).toEqual(true);
            httpBackend.flush();
            expect(instance.archived).toEqual(true);
          });
        });

        describe('on failure', function () {
          beforeEach(function () {
            httpBackend.expectPOST('/objects/7/archive.json').respond(400);
            instance.toggleArchive();
          });

          it('resets the archived value', function () {
            httpBackend.flush();
            expect(instance.archived).toEqual(false);
          });
        });
      });
    });
  });
});