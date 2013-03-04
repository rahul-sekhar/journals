'use strict';

describe('people module', function() {
  beforeEach(module('journals.people'));


  /* --------------- People controller --------------------- */

  describe('PeopleCtrl', function() {
    var scope, route, ctrl, PeopleInterface, location, deferred_result, messageHandler;

    beforeEach(inject(function($rootScope, $location, $q, _PeopleInterface_) {
      scope = $rootScope.$new();
      route = {};
      route.current = { filterName: 'Some filter' };
      PeopleInterface = _PeopleInterface_;
      deferred_result = $q.defer();
      spyOn(PeopleInterface, 'query').andReturn(deferred_result.promise);
      spyOn(PeopleInterface, 'get').andReturn(deferred_result.promise);
      location = $location
      location.url('/current_path');
      messageHandler = { showError: jasmine.createSpy() };
    }));

    describe('for pages with many people', function() {
      beforeEach(inject(function($controller) {
        ctrl = $controller('PeopleCtrl', { $scope: scope, $route: route, PeopleInterface: PeopleInterface, messageHandler: messageHandler });
      }));

      it('sets filterName from the route', function() {
        scope.filterName.should == 'Some filter';
      });

      it('sets singlePerson to false', function() {
        expect(scope.singlePerson).toEqual(false);
      });

      it('sets pageTitle to the title', function() {
        expect(scope.pageTitle).toEqual('People');
      });

      it('loads data through PeopleInterface', function() {
        expect(PeopleInterface.query).toHaveBeenCalledWith('/current_path');
      });

      it('sets the scope data when the promise is resolved', function() {
        expect(scope.people).toBeUndefined();
        deferred_result.resolve({people: ['person1', 'person2'], metadata: { current_page: 3, total_pages: 7 }});
        scope.$apply();
        expect(scope.people).toEqual(['person1', 'person2']);
        expect(scope.currentPage).toEqual(3);
        expect(scope.totalPages).toEqual(7);
      });

      it('shows an error message when the promise is rejected', function() {
        deferred_result.reject('Some error message');
        scope.$apply();
        expect(messageHandler.showError).toHaveBeenCalledWith('Some error message');
      });

      describe('doSearch()', function() {
        it('updates the location param', inject(function($location) {
          scope.doSearch('some value');
          expect($location.search().search).toEqual('some value');
        }));

        it('reloads data through PeopleInterface', function() {
          scope.doSearch('some value');
          scope.$broadcast('$routeUpdate');
          expect(PeopleInterface.query.mostRecentCall.args).toEqual([encodeURI('/current_path?search=some value')]);
        });
      });
    });

    describe('for a single person', function() {
      beforeEach(inject(function($controller) {
        ctrl = $controller('PeopleCtrl', { 
          $scope: scope,
          $route: route, 
          PeopleInterface: PeopleInterface, 
          messageHandler: messageHandler,
          $routeParams: { id: 5 }
        });
      }));

      it('sets singlePerson to true', function() {
        expect(scope.singlePerson).toEqual(true);
      });

      it('does not set filterName', function() {
        expect(scope.filterName).toBeUndefined();
      });

      it('sets pageTitle', function() {
        expect(scope.pageTitle).toEqual('Profile');
      });

      it('loads data through PeopleInterface', function() {
        expect(PeopleInterface.get).toHaveBeenCalledWith('/current_path');
      });

      it('initially has its people data undefined', function() {
        expect(scope.people).toBeUndefined();
      });

      describe('when the promise is resolved', function() {
        beforeEach(function() {
          deferred_result.resolve({person: {
            full_name: 'Some person',
            field: 'some value'
          }});
          scope.$apply();
        });

        it('sets the people data', function() {
          expect(scope.people).toEqual([{
            full_name: 'Some person',
            field: 'some value'
          }]);
        });

        it('sets the pageTitle', function() {
          expect(scope.pageTitle).toEqual('Profile: Some person');
        })
      });

      describe('when the promise is resolved with a guardian', function() {
        beforeEach(function() {
          deferred_result.resolve({person: {
            full_name: 'Some person',
            type: 'Guardian',
            students: [
              {full_name: 'Student A'},
              {full_name: 'Student B'}
            ],
            field: 'some value'
          }});
          scope.$apply();
        });

        it('sets the people data to the students', function() {
          expect(scope.people).toEqual([
            {full_name: 'Student A'},
            {full_name: 'Student B'}
          ]);
        });

        it('sets the pageTitle', function() {
          expect(scope.pageTitle).toEqual('Profile: Some person');
        })
      });

      describe('when the promise is rejected', function() {
        beforeEach(function() {
          deferred_result.reject('Some error object');
          scope.$apply();
        });

        it('shows an error message when the promise is', function() {
          expect(messageHandler.showError).toHaveBeenCalledWith('Some error object');
        });

        it('sets the pageTitle', function() {
          expect(scope.pageTitle).toEqual('Profile not found');
        })
      });

      it('has no doSearch method', function() {
        expect(scope.doSearch).toBeUndefined();
      });
    });
  });

  
  /* ------------ Person ----------------- */

  describe('Person', function() {
    var Person, messageHandler;

    beforeEach(module(function($provide) {
      messageHandler = { showError: jasmine.createSpy() };
      $provide.value('messageHandler', messageHandler);
    }));

    beforeEach(inject(function(_Person_) {
      Person = _Person_;
    }));

    describe('create()', function() {
      var person, inputData;

      beforeEach(function() {
        inputData = {
          type: 'Student',
          id: 7,
          field1: 'value 1',
          field2: 'value 2'
        };
        person = Person.create(inputData);
      });

      it('preserves input data', function() {
        expect(person.field1).toEqual('value 1');
        expect(person.field2).toEqual('value 2');
      });

      it('sets a blank editing object', function() {
        expect(person.editing).toEqual({});
      });

      it('throws an exception if type is not valid', function() {
        inputData = {
          type: 'Something'
        };
        expect(function() { Person.create(inputData) }).toThrow('Invalid type for person');
      });

      describe('url()', function() {
        it('throws an exception if id is not present', function() {
          person.type = 'Student';
          person.id = null
          expect(person.url).toThrow('Invalid id for person');
        });

        it('gets the url for a student', function() {
          person.type = 'Student';
          person.id = 7;
          expect(person.url()).toEqual('/students/7')
        });

        it('gets the url for a teacher', function() {
          person.type = 'Teacher';
          person.id = 17;
          expect(person.url()).toEqual('/teachers/17')
        });

        it('gets the url for a guardian', function() {
          person.type = 'Guardian';
          person.id = 1;
          expect(person.url()).toEqual('/guardians/1')
        });
      });

      describe('conversion of contained people', function() {
        var oldCreate;

        beforeEach(function() {
          oldCreate = Person.create;
          Person.create = function(input) {
            return 'converted ' + input;
          }
        });

        describe('guardians', function() {
          it('is not touched if not a student', function() {
            inputData = {
              type: 'Teacher',
              guardians: ['A', 'B']
            };
            person = oldCreate(inputData);
            expect(person.guardians).toEqual(['A', 'B']);
          });

          it('is converted into a person object array if a student', function() {
            inputData = {
              type: 'Student',
              guardians: ['A', 'B']
            };
            person = oldCreate(inputData);
            expect(person.guardians).toEqual(['converted A', 'converted B']);
          });
        });

        describe('students', function() {
          it('is not touched if not a guardian', function() {
            inputData = {
              type: 'Student',
              students: ['A', 'B']
            };
            person = oldCreate(inputData);
            expect(person.students).toEqual(['A', 'B']);
          });

          it('is converted into a person object array if a guardian', function() {
            inputData = {
              type: 'Guardian',
              students: ['A', 'B']
            };
            person = oldCreate(inputData);
            expect(person.students).toEqual(['converted A', 'converted B']);
          });
        });
      });

      describe('fields', function() {
        it('sets a students fields', function() {
          inputData = {
            type: 'Student'
          };
          person = Person.create(inputData);
          var field_names = person.fields.map(function(obj) {
            return obj.slug;
          });
          expect(field_names).toEqual([
            "formatted_birthday",
            "blood_group",
            "mobile",
            "home_phone",
            "office_phone",
            "email",
            "additional_emails",
            "address",
            "notes"
          ]);
        });

        it('returns a teachers fields', function() {
          inputData = {
            type: 'Teacher'
          };
          person = Person.create(inputData);
          var field_names = person.fields.map(function(obj) {
            return obj.slug;
          });
          expect(field_names).toEqual([
            "mobile",
            "home_phone",
            "office_phone",
            "email",
            "additional_emails",
            "address",
            "notes"
          ]);
        });

        it('returns a guardians fields', function() {
          inputData = {
            type: 'Guardian'
          };
          person = Person.create(inputData);
          var field_names = person.fields.map(function(obj) {
            return obj.slug;
          });
          expect(field_names).toEqual([
            "mobile",
            "home_phone",
            "office_phone",
            "email",
            "additional_emails",
            "address",
            "notes"
          ]);
        });
      });

      describe('remainingFields()', function() {
        it('returns non bank fields', function() {
          person.home_phone = 'blah blah';
          person.address='something'
          person.email = null;
          person.mobile = ''
          person.blood_group = 'A+'

          var field_names = person.remainingFields().map(function(obj) {
            return obj.slug;
          });

          expect(field_names).toEqual([
            "formatted_birthday",
            "mobile",
            "office_phone",
            "email",
            "additional_emails",
            "notes"
          ]);
        });
      });

      describe('addField(field_name)', function() {
        beforeEach(function() {
          person.addField('some_field');
        });

        it('sets editing to true for that field', function() {
          expect(person.editing['some_field']).toEqual(true);
        });
      });

      describe('update(field_name, value)', function() {
        var httpBackend;

        beforeEach(inject(function($httpBackend) {
          httpBackend = $httpBackend;
        }));

        describe('new field', function() {
          describe('with a valid server response', function() {
            beforeEach(function() {
              httpBackend.expectPUT('/students/7', {
                student: { field3: 'new field value' }
              }).respond({
                type: 'Student',
                id: 7,
                field3: 'formatted field value'
              });
              person.update('field3', 'new field value');
            });

            it('updates the field in the model', function() {
              expect(person.field3).toEqual('new field value');
            });

            it('sends a message to the server', function() {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('updates the model field with the server response', function() {
              httpBackend.flush();
              expect(person.field3).toEqual('formatted field value');
            });
          });
          
          describe('with an invalid server response', function() {
            beforeEach(function() {
              httpBackend.expectPUT('/students/7', {
                student: { field3: 'new field value' }
              }).respond(422, 'Some error');
              person.update('field3', 'new field value');
            });

            it('updates the field in the model', function() {
              expect(person.field3).toEqual('new field value');
            });

            it('sends a message to the server', function() {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('restores the model field to an empty value with the server response', function() {
              httpBackend.flush();
              expect(person.field3).toBeUndefined();
            });

            it('displays an error message', function() {
              httpBackend.flush();
              expect(messageHandler.showError).toHaveBeenCalled();
            });
          });
        });

        describe('changed value', function() {
          describe('with a valid server response', function() {
            beforeEach(function() {
              httpBackend.expectPUT('/students/7', {
                student: { field2: 'new value' }
              }).respond({
                type: 'Student',
                id: 7,
                field2: 'formatted value'
              });
              person.update('field2', 'new value');
            });

            it('updates the field in the model', function() {
              expect(person.field2).toEqual('new value');
            });

            it('sends a message to the server', function() {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('updates the model field with the server response', function() {
              httpBackend.flush();
              expect(person.field2).toEqual('formatted value');
            });
          });
          
          describe('with an invalid server response', function() {
            beforeEach(function() {
              httpBackend.expectPUT('/students/7', {
                student: { field2: 'new value' }
              }).respond(422, 'Some error');
              person.update('field2', 'new value');
            });

            it('updates the field in the model', function() {
              expect(person.field2).toEqual('new value');
            });

            it('sends a message to the server', function() {
              httpBackend.verifyNoOutstandingExpectation();
            });

            it('restores the model field to the old value with the server response', function() {
              httpBackend.flush();
              expect(person.field2).toEqual('value 2');
            });

            it('displays an error message', function() {
              httpBackend.flush();
              expect(messageHandler.showError).toHaveBeenCalled();
            });
          }); 
        });

        describe('unchanged value', function() {
          beforeEach(function() {
            person.update('field2', 'value 2');
          });

          it('leaves the field value unchanged and does not contact the server', function() {
            expect(person.field2).toEqual('value 2');
          });
        });
      });
    });

    describe('createFromArray()', function() {
      var result, args;

      beforeEach(function() {
        args = [];
        Person.create = function(string) {
          args.push(string);
          return string + ' object';
        };
        result = Person.createFromArray(['a', 'b', 'c']);
      });

      it('calls create with each value of the array', function() {
        expect(args).toEqual(['a', 'b', 'c']);
      });

      it('returns an array transformed into person objects', function() {
        expect(result).toEqual(['a object', 'b object', 'c object']);
      });
    })
  });

  /* ---------- PeopleInterface -------------- */

  describe('PeopleInterface', function() {
    var PeopleInterface, httpBackend, Person;

    beforeEach(inject(function(_PeopleInterface_, _Person_, $httpBackend) {
      PeopleInterface = _PeopleInterface_;
      httpBackend = $httpBackend;
      Person = _Person_;
      spyOn(Person, 'create').andReturn('person object');
      spyOn(Person, 'createFromArray').andReturn(['person object 1', 'person object 2']);
    }));

    
    // Query function
    describe('query()', function() {
      describe('valid response', function() {
        var promise, response, error;

        beforeEach(function() {
          httpBackend.expectGET('some_url').respond({
            data1: 'something',
            data2: 'something else',
            items: ['A', 'B']
          });
          response = undefined, error = undefined;
          promise = PeopleInterface.query('some_url').then(
            function(data) { response = data; },
            function(data) { error = data; }
          );
        });

        it('sends a GET request', function() {
          httpBackend.verifyNoOutstandingExpectation();
        });

        it('responds with metadata', function() {
          httpBackend.flush();
          expect(response.metadata).toEqual({ data1: 'something', data2: 'something else' });
        });

        it('responds with the people created by the Person object', function() {
          httpBackend.flush();
          expect(Person.createFromArray).toHaveBeenCalledWith(['A', 'B'])
          expect(response.people).toEqual(['person object 1', 'person object 2']);
        });
      });

      describe('invalid response', function() {
        var promise, response, error;

        beforeEach(function() {
          httpBackend.expectGET('some_url').respond(404, 'Some error')
          response = undefined, error = undefined;
          promise = PeopleInterface.query('some_url').then(
            function(data) { response = data; },
            function(data) { error = data; }
          );
        });

        it('rejects the response with the error object', function() {
          httpBackend.flush();
          expect(error.status).toEqual(404);
          expect(error.data).toEqual('Some error');
        });
      });
    });
  
    
    // Get function
    describe('get()', function() {
      describe('valid response', function() {
        var promise, response, error;

        beforeEach(function() {
          httpBackend.expectGET('some_url').respond({
            data1: 'something',
            data2: 'something else',
          });
          response = undefined, error = undefined;
          promise = PeopleInterface.get('some_url').then(
            function(data) { response = data; },
            function(data) { error = data; }
          );
        });

        it('sends a GET request', function() {
          httpBackend.verifyNoOutstandingExpectation();
        });

        it('responds with a person created by the Person object', function() {
          httpBackend.flush();
          expect(Person.create).toHaveBeenCalledWith({ data1: 'something', data2: 'something else' })
          expect(response.person).toEqual('person object');
        });
      });

      describe('invalid response', function() {
        var promise, response, error;

        beforeEach(function() {
          httpBackend.expectGET('some_url').respond(404, 'Some error')
          response = undefined, error = undefined;
          promise = PeopleInterface.query('some_url').then(
            function(data) { response = data; },
            function(data) { error = data; }
          );
        });

        it('rejects the response with the error object', function() {
          httpBackend.flush();
          expect(error.status).toEqual(404);
          expect(error.data).toEqual('Some error');
        });
      });
    });
  });
  

  /*---------------- Date with age filter ---------------*/

  describe('dateWithAge', function() {
    var currentDateMock

    beforeEach(function() {
      module(function($provide) {
        currentDateMock = {
          get: function() {
            return new Date('2013-01-01')
          }
        };
        $provide.value('currentDate', currentDateMock)
      });
    });

    it('converts a date to an age', inject(function(dateWithAgeFilter) {
      expect(dateWithAgeFilter('24-04-2007')).toEqual('24-04-2007 (5 yrs)');
    }));

    it('returns null for a null date', inject(function(dateWithAgeFilter) {
      expect(dateWithAgeFilter(null)).toEqual(null);
    }));

    it('returns null for a blank date', inject(function(dateWithAgeFilter) {
      expect(dateWithAgeFilter('')).toEqual(null);
    }));
  });
});