'use strict';

describe('People module', function() {
  beforeEach(module('journals.people'));

  /*------------------- People base controller -----------------------*/

  describe('peopleBaseCtrl', function() {
    var scope, location, confirm;

    beforeEach(inject(function($rootScope, peopleBaseCtrl, $location, _confirm_) {
      location = $location;
      confirm = _confirm_;

      scope = $rootScope.$new();
      scope.load = jasmine.createSpy();

      peopleBaseCtrl(scope);
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

    // Delete a profile
    describe('delete(profile)', function() {
      var profile;

      beforeEach(function() {
        profile = { delete: jasmine.createSpy() };
      });

      describe('on confirm', function() {
        beforeEach(function() {
          scope.delete(profile)
        });

        it('sends a delete message to the profile', function() {
          expect(profile.delete).toHaveBeenCalled();
        });
      });

      describe('on cancel', function() {
        beforeEach(function() {
          confirm.set(false);
          scope.delete(profile)
        });

        it('does not send a delete message to the profile', function() {
          expect(profile.delete).not.toHaveBeenCalled();
        });
      });
    });

    // Reset password
    describe('resetPassword(profile)', function() {
      var profile;

      beforeEach(function() {
        profile = { resetPassword: jasmine.createSpy() };
      });

      describe('on confirm', function() {
        beforeEach(function() {
          scope.resetPassword(profile)
        });

        it('sends a resetPassword message to the profile', function() {
          expect(profile.resetPassword).toHaveBeenCalled();
        });
      });

      describe('on cancel', function() {
        beforeEach(function() {
          confirm.set(false);
          scope.resetPassword(profile)
        });

        it('does not send a resetPassword message to the profile', function() {
          expect(profile.resetPassword).not.toHaveBeenCalled();
        });
      });
    });

    // toggle archive
    describe('toggleArchive(profile)', function() {
      var profile;

      beforeEach(function() {
        profile = { toggleArchive: jasmine.createSpy() };
      });

      describe('for an archived user', function() {
        beforeEach(function() {
          profile.archived = true;
          scope.toggleArchive(profile)
        });

        it('does not call confirm', function() {
          expect(confirm).not.toHaveBeenCalled();
        });

        it('sends a removeGuardian message to the profile', function() {
          expect(profile.toggleArchive).toHaveBeenCalled();
        });
      });

      describe('for an unarchived user', function() {
        describe('on confirm', function() {
          beforeEach(function() {
            scope.toggleArchive(profile)
          });

          it('does calls confirm', function() {
            expect(confirm).toHaveBeenCalled();
          });

          it('sends a toggleArchive message to the profile', function() {
            expect(profile.toggleArchive).toHaveBeenCalled();
          });
        });

        describe('on cancel', function() {
          beforeEach(function() {
            confirm.set(false);
            scope.toggleArchive(profile)
          });

          it('does not send a toggleArchive message to the profile', function() {
            expect(profile.toggleArchive).not.toHaveBeenCalled();
          });
        });
      });
    });


    // remove a guardian
    describe('removeGuardian(profile, guardian)', function() {
      var profile, guardian;

      beforeEach(function() {
        profile = { removeGuardian: jasmine.createSpy() };
        guardian = {};
      });

      describe('with number_of_students > 1', function() {
        beforeEach(function() {
          guardian.number_of_students = 2;
          scope.removeGuardian(profile, guardian)
        });

        it('does not call confirm', function() {
          expect(confirm).not.toHaveBeenCalled();
        });

        it('sends a removeGuardian message to the profile', function() {
          expect(profile.removeGuardian).toHaveBeenCalledWith(guardian);
        });
      });

      describe('with number_of_students = 1', function() {
        beforeEach(function() {
          guardian.number_of_students = 1;
        });

        describe('on confirm', function() {
          beforeEach(function() {
            scope.removeGuardian(profile, guardian)
          });

          it('does calls confirm', function() {
            expect(confirm).toHaveBeenCalled();
          });

          it('sends a removeGuardian message to the profile', function() {
            expect(profile.removeGuardian).toHaveBeenCalledWith(guardian);
          });
        });

        describe('on cancel', function() {
          beforeEach(function() {
            confirm.set(false);
            scope.removeGuardian(profile, guardian);
          });

          it('does not send a removeGuardian message to the profile', function() {
            expect(profile.removeGuardian).not.toHaveBeenCalled();
          });
        });
      });
    });
  });

  /*------------------ Load people collection service -----------------*/

  describe('loadPeopleCollection', function() {
    var scope, peopleInterface, location, deferred, Groups;

    beforeEach(inject(function($rootScope, peopleBaseCtrl, _peopleInterface_, $q, $location, loadPeopleCollection, _Groups_) {
      deferred = $q.defer();

      peopleInterface = _peopleInterface_;
      spyOn(peopleInterface, 'load').andReturn(deferred.promise);

      location = $location;
      location.url('/some/path');

      Groups = _Groups_;
      spyOn(Groups, 'all').andReturn('group array');

      scope = $rootScope.$new();
      loadPeopleCollection(scope);
    }));

    it('loads groups', function() {
      expect(Groups.all).toHaveBeenCalled();
      expect(scope.groups).toEqual('group array');
    });

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

    beforeEach(inject(function($rootScope, peopleBaseCtrl, _peopleInterface_, $q, $location, loadProfile) {
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
    var scope, peopleBaseCtrl, loadProfile;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();
      loadProfile = jasmine.createSpy();

      $controller('ProfileCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
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
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  /*------------------- People controllers -----------------------*/

  describe('PeopleCtrl', function() {
    var scope, peopleBaseCtrl, loadPeopleCollection;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();
      loadPeopleCollection = jasmine.createSpy();

      $controller('PeopleCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
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
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  describe('ArchivedPeopleCtrl', function() {
    var scope, peopleBaseCtrl, loadPeopleCollection;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();
      loadPeopleCollection = jasmine.createSpy();

      $controller('ArchivedPeopleCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
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
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  describe('TeachersCtrl', function() {
    var scope, peopleBaseCtrl, loadPeopleCollection;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();
      loadPeopleCollection = jasmine.createSpy();

      $controller('TeachersCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
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
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  describe('StudentsCtrl', function() {
    var scope, peopleBaseCtrl, loadPeopleCollection;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();
      loadPeopleCollection = jasmine.createSpy();

      $controller('StudentsCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
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
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  describe('MenteesCtrl', function() {
    var scope, peopleBaseCtrl, loadPeopleCollection;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();
      loadPeopleCollection = jasmine.createSpy();

      $controller('MenteesCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
        loadPeopleCollection: loadPeopleCollection
      });
    }));

    it('sets the page title', function() {
      expect(scope.pageTitle).toEqual('Mentees');
    });

    it('sets canAddStudent', function() {
      expect(scope.canAddStudent).toEqual(false);
    });

    it('sets canAddTeacher', function() {
      expect(scope.canAddTeacher).toEqual(false);
    });

    it('sets the filterName', function() {
      expect(scope.filterName).toEqual('Your mentees');
    });

    it('includes loadPeopleCollection', function() {
      expect(loadPeopleCollection).toHaveBeenCalledWith(scope);
    });

    it('includes the base controller', function() {
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  /*--------------- GroupsPage controller --------------------*/

  describe('GroupsPageCtrl', function() {
    var scope, peopleBaseCtrl, loadPeopleCollection, Groups, deferred;

    beforeEach(inject(function($rootScope, $controller, _Groups_, $q) {
      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();
      loadPeopleCollection = jasmine.createSpy();

      deferred = $q.defer();
      Groups = _Groups_;
      spyOn(Groups, 'get').andReturn(deferred.promise)

      $controller('GroupsPageCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
        loadPeopleCollection: loadPeopleCollection,
        $routeParams: { id: '4' }
      });
    }));

    it('sets the page title', function() {
      expect(scope.pageTitle).toEqual('Group');
    });

    it('sets the filterName', function() {
      expect(scope.filterName).toEqual('Group');
    });

    it('gets the group from the Groups collection', function() {
      expect(Groups.get).toHaveBeenCalledWith(4);
    });

    describe('when the group is found', function() {
      beforeEach(function() {
        deferred.resolve({id: 4, name: 'Some group'});
        scope.$apply();
      });

      it('sets the page title', function() {
        expect(scope.pageTitle).toEqual('Group: Some group');
      });

      it('sets the filterName', function() {
        expect(scope.filterName).toEqual('Some group');
      });
    });

    describe('when the group is not found', function() {
      beforeEach(function() {
        deferred.reject();
        scope.$apply();
      });

      it('sets the page title', function() {
        expect(scope.pageTitle).toEqual('Group: Not found');
      });

      it('sets the filterName', function() {
        expect(scope.filterName).toEqual('Unknown group');
      });
    });

    it('sets canAddStudent', function() {
      expect(scope.canAddStudent).toEqual(false);
    });

    it('sets canAddTeacher', function() {
      expect(scope.canAddTeacher).toEqual(false);
    });

    it('includes loadPeopleCollection', function() {
      expect(loadPeopleCollection).toHaveBeenCalledWith(scope);
    });

    it('includes the base controller', function() {
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });
});