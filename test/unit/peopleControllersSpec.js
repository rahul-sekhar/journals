'use strict';

describe('People controllers module', function() {
  beforeEach(module('journals.people.controllers'));

  /*------------------- People base controller -----------------------*/

  describe('PeopleBaseCtrl', function() {
    var scope, location;

    beforeEach(inject(function($rootScope, PeopleBaseCtrl, $location) {
      location = $location;

      scope = $rootScope.$new();
      scope.load = jasmine.createSpy();
      
      PeopleBaseCtrl(scope);
    }));

    it('loads data initially', function() {
      expect(scope.load).toHaveBeenCalled();
    });

    it('reloads data on a route update', function() {
      scope.load.reset();
      scope.$broadcast('$routeUpdate');
      expect(scope.load).toHaveBeenCalled();
    });

    describe('doSearch()', function() {
      it('updates the location param', function() {
        scope.doSearch('some value');
        expect(location.search().search).toEqual('some value');
      });
    });
  });

  /*------------------ Load people collection service -----------------*/

  describe('loadPeopleCollection', function() {
    var scope, peopleInterface, location, deferred;

    beforeEach(inject(function($rootScope, PeopleBaseCtrl, _peopleInterface_, $q, $location, loadPeopleCollection) {
      deferred = $q.defer();

      peopleInterface = _peopleInterface_;
      spyOn(peopleInterface, 'load').andReturn(deferred.promise);

      location = $location;
      location.url('/some/path');

      scope = $rootScope.$new();
      loadPeopleCollection(scope);
    }));

    describe('scope.load()', function() {
      beforeEach(function() {
        scope.load();
      });

      it('loads people through the interface', function() {
        expect(peopleInterface.load).toHaveBeenCalledWith('/some/path');
      });

      it('initially has people undefined', function() {
        expect(scope.people).toBeUndefined();
      });

      describe('when the promise is resolved', function() {
        beforeEach(function() {
          deferred.resolve({
            metadata: { current_page: 1, total_pages: 3 },
            people: 'people array'
          });
          scope.$apply();
        });

        it('sets people', function() {
          expect(scope.people).toEqual('people array');
        });

        it('sets the page data', function() {
          expect(scope.totalPages).toEqual(3);
          expect(scope.currentPage).toEqual(1);
        });
      });

      describe('when the promise is rejected', function() {
        beforeEach(function() {
          deferred.reject();
          scope.$apply();
        });

        it('leaves people as it is', function() {
          expect(scope.people).toBeUndefined();
        });
      });
    });
  });

  /*------------------ Load profile service -----------------*/
  
  describe('loadProfile', function() {
    var scope, peopleInterface, location, deferred;

    beforeEach(inject(function($rootScope, PeopleBaseCtrl, _peopleInterface_, $q, $location, loadProfile) {
      deferred = $q.defer();

      peopleInterface = _peopleInterface_;
      spyOn(peopleInterface, 'loadProfile').andReturn(deferred.promise);

      location = $location;
      location.url('/some/path');

      scope = $rootScope.$new();
      loadProfile(scope);
    }));

    describe('scope.load()', function() {
      beforeEach(function() {
        scope.load();
      });

      it('loads people through the interface', function() {
        expect(peopleInterface.loadProfile).toHaveBeenCalledWith('/some/path');
      });

      it('initially has people undefined', function() {
        expect(scope.people).toBeUndefined();
      });

      describe('when the promise is resolved', function() {
        beforeEach(function() {
          deferred.resolve({
            name: 'Some name',
            people: 'people array'
          });
          scope.$apply();
        });

        it('sets people', function() {
          expect(scope.people).toEqual('people array');
        });

        it('sets the page title', function() {
          expect(scope.pageTitle).toEqual('Profile: Some name');
        });
      });

      describe('when the promise is rejected', function() {
        beforeEach(function() {
          deferred.reject();
          scope.$apply();
        });

        it('leaves people as it is', function() {
          expect(scope.people).toBeUndefined();
        });

        it('sets the page title', function() {
          expect(scope.pageTitle).toEqual('Profile: Not found');
        });
      });
    });
  });

  /*------------------- Profile controller ----------------------*/
  describe('ProfileCtrl', function() {
    var scope, PeopleBaseCtrl, loadProfile;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      PeopleBaseCtrl = jasmine.createSpy();
      loadProfile = jasmine.createSpy();

      $controller('ProfileCtrl', {
        $scope: scope, 
        PeopleBaseCtrl: PeopleBaseCtrl, 
        loadProfile: loadProfile 
      });
    }));

    it('sets the page title', function() {
      expect(scope.pageTitle).toEqual('Profile');
    });

    it('sets profile', function() {
      expect(scope.profile).toEqual(true);
    });
    
    it('includes loadProfile', function() {
      expect(loadProfile).toHaveBeenCalledWith(scope);
    });

    it('includes the base controller', function() {
      expect(PeopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  /*------------------- People controllers -----------------------*/
  
  describe('PeopleCtrl', function() {
    var scope, PeopleBaseCtrl, loadPeopleCollection;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      PeopleBaseCtrl = jasmine.createSpy();
      loadPeopleCollection = jasmine.createSpy();

      $controller('PeopleCtrl', {
        $scope: scope, 
        PeopleBaseCtrl: PeopleBaseCtrl, 
        loadPeopleCollection: loadPeopleCollection 
      });
    }));

    it('sets the page title', function() {
      expect(scope.pageTitle).toEqual('People');
    });

    it('sets canAddStudent', function() {
      expect(scope.canAddStudent).toEqual(true);
    });

    it('sets canAddTeacher', function() {
      expect(scope.canAddTeacher).toEqual(true);
    });

    it('sets the filterName', function() {
      expect(scope.filterName).toEqual('Students and teachers');
    });

    it('includes loadPeopleCollection', function() {
      expect(loadPeopleCollection).toHaveBeenCalledWith(scope);
    });

    it('includes the base controller', function() {
      expect(PeopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  describe('ArchivedPeopleCtrl', function() {
    var scope, PeopleBaseCtrl, loadPeopleCollection;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      PeopleBaseCtrl = jasmine.createSpy();
      loadPeopleCollection = jasmine.createSpy();

      $controller('ArchivedPeopleCtrl', {
        $scope: scope, 
        PeopleBaseCtrl: PeopleBaseCtrl, 
        loadPeopleCollection: loadPeopleCollection 
      });
    }));

    it('sets the page title', function() {
      expect(scope.pageTitle).toEqual('Archived');
    });

    it('sets canAddStudent', function() {
      expect(scope.canAddStudent).toEqual(false);
    });

    it('sets canAddTeacher', function() {
      expect(scope.canAddTeacher).toEqual(false);
    });

    it('sets the filterName', function() {
      expect(scope.filterName).toEqual('Archived students and teachers');
    });

    it('includes loadPeopleCollection', function() {
      expect(loadPeopleCollection).toHaveBeenCalledWith(scope);
    });

    it('includes the base controller', function() {
      expect(PeopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  describe('TeachersCtrl', function() {
    var scope, PeopleBaseCtrl, loadPeopleCollection;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      PeopleBaseCtrl = jasmine.createSpy();
      loadPeopleCollection = jasmine.createSpy();

      $controller('TeachersCtrl', {
        $scope: scope, 
        PeopleBaseCtrl: PeopleBaseCtrl, 
        loadPeopleCollection: loadPeopleCollection 
      });
    }));

    it('sets the page title', function() {
      expect(scope.pageTitle).toEqual('Teachers');
    });

    it('sets canAddStudent', function() {
      expect(scope.canAddStudent).toEqual(false);
    });

    it('sets canAddTeacher', function() {
      expect(scope.canAddTeacher).toEqual(true);
    });

    it('sets the filterName', function() {
      expect(scope.filterName).toEqual('Teachers');
    });

    it('includes loadPeopleCollection', function() {
      expect(loadPeopleCollection).toHaveBeenCalledWith(scope);
    });

    it('includes the base controller', function() {
      expect(PeopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  describe('StudentsCtrl', function() {
    var scope, PeopleBaseCtrl, loadPeopleCollection;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      PeopleBaseCtrl = jasmine.createSpy();
      loadPeopleCollection = jasmine.createSpy();

      $controller('StudentsCtrl', {
        $scope: scope, 
        PeopleBaseCtrl: PeopleBaseCtrl, 
        loadPeopleCollection: loadPeopleCollection 
      });
    }));

    it('sets the page title', function() {
      expect(scope.pageTitle).toEqual('Students');
    });

    it('sets canAddStudent', function() {
      expect(scope.canAddStudent).toEqual(true);
    });

    it('sets canAddTeacher', function() {
      expect(scope.canAddTeacher).toEqual(false);
    });

    it('sets the filterName', function() {
      expect(scope.filterName).toEqual('Students');
    });

    it('includes loadPeopleCollection', function() {
      expect(loadPeopleCollection).toHaveBeenCalledWith(scope);
    });

    it('includes the base controller', function() {
      expect(PeopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });
});