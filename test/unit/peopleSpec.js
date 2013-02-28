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
        deferred_result.resolve({people: ['person1', 'person2'], metadata: { currentPage: 3, totalPages: 7 }});
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
    var Person;

    beforeEach(inject(function(_Person_) {
      Person = _Person_;
    }));

    describe('create()', function() {

    });
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
        var response, error;

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
        var response, error;

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
        var response, error;

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
        var response, error;

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
});