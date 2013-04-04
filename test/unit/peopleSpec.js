'use strict';

describe('People module', function () {
  beforeEach(module('journals.people'));

  /*------------------- People base controller -----------------------*/

  describe('peopleBaseCtrl', function () {
    var scope, confirm;

    beforeEach(inject(function ($rootScope, peopleBaseCtrl, _confirm_) {
      confirm = _confirm_;

      scope = $rootScope.$new();
      scope.load = jasmine.createSpy();

      peopleBaseCtrl(scope);
    }));

    // Delete a profile
    describe('delete(profile)', function () {
      var profile;

      beforeEach(function () {
        profile = { delete: jasmine.createSpy() };
      });

      describe('on confirm', function () {
        beforeEach(function () {
          scope.delete(profile)
        });

        it('sends a delete message to the profile', function () {
          expect(profile.delete).toHaveBeenCalled();
        });
      });

      describe('on cancel', function () {
        beforeEach(function () {
          confirm.set(false);
          scope.delete(profile)
        });

        it('does not send a delete message to the profile', function () {
          expect(profile.delete).not.toHaveBeenCalled();
        });
      });
    });

    // removeGroup
    describe('removeGroup(profile, group)', function () {
      var profile;

      beforeEach(function () {
        profile = { removeGroup: jasmine.createSpy() };
      });

      describe('on confirm', function () {
        beforeEach(function () {
          scope.removeGroup(profile, 'obj')
        });

        it('sends a message to the profile', function () {
          expect(profile.removeGroup).toHaveBeenCalledWith('obj');
        });
      });

      describe('on cancel', function () {
        beforeEach(function () {
          confirm.set(false);
          scope.removeGroup(profile, 'obj')
        });

        it('does not send a delete message to the profile', function () {
          expect(profile.removeGroup).not.toHaveBeenCalled();
        });
      });
    });

    // removeMentor
    describe('removeMentor(profile, mentor)', function () {
      var profile;

      beforeEach(function () {
        profile = { removeMentor: jasmine.createSpy() };
      });

      describe('on confirm', function () {
        beforeEach(function () {
          scope.removeMentor(profile, 'obj')
        });

        it('sends a message to the profile', function () {
          expect(profile.removeMentor).toHaveBeenCalledWith('obj');
        });
      });

      describe('on cancel', function () {
        beforeEach(function () {
          confirm.set(false);
          scope.removeMentor(profile, 'obj')
        });

        it('does not send a delete message to the profile', function () {
          expect(profile.removeMentor).not.toHaveBeenCalled();
        });
      });
    });

    // removeMentee
    describe('removeMentee(profile, mentee)', function () {
      var profile;

      beforeEach(function () {
        profile = { removeMentee: jasmine.createSpy() };
      });

      describe('on confirm', function () {
        beforeEach(function () {
          scope.removeMentee(profile, 'obj')
        });

        it('sends a message to the profile', function () {
          expect(profile.removeMentee).toHaveBeenCalledWith('obj');
        });
      });

      describe('on cancel', function () {
        beforeEach(function () {
          confirm.set(false);
          scope.removeMentee(profile, 'obj')
        });

        it('does not send a delete message to the profile', function () {
          expect(profile.removeMentee).not.toHaveBeenCalled();
        });
      });
    });

    // Reset password
    describe('resetPassword(profile)', function () {
      var profile;

      beforeEach(function () {
        profile = { resetPassword: jasmine.createSpy() };
      });

      describe('on confirm', function () {
        beforeEach(function () {
          scope.resetPassword(profile)
        });

        it('sends a resetPassword message to the profile', function () {
          expect(profile.resetPassword).toHaveBeenCalled();
        });
      });

      describe('on cancel', function () {
        beforeEach(function () {
          confirm.set(false);
          scope.resetPassword(profile)
        });

        it('does not send a resetPassword message to the profile', function () {
          expect(profile.resetPassword).not.toHaveBeenCalled();
        });
      });
    });

    // toggle archive
    describe('toggleArchive(profile)', function () {
      var profile;

      beforeEach(function () {
        profile = { toggleArchive: jasmine.createSpy() };
      });

      describe('for an archived user', function () {
        beforeEach(function () {
          profile.archived = true;
          scope.toggleArchive(profile)
        });

        it('does not call confirm', function () {
          expect(confirm).not.toHaveBeenCalled();
        });

        it('sends a removeGuardian message to the profile', function () {
          expect(profile.toggleArchive).toHaveBeenCalled();
        });
      });

      describe('for an unarchived user', function () {
        describe('on confirm', function () {
          beforeEach(function () {
            scope.toggleArchive(profile)
          });

          it('does calls confirm', function () {
            expect(confirm).toHaveBeenCalled();
          });

          it('sends a toggleArchive message to the profile', function () {
            expect(profile.toggleArchive).toHaveBeenCalled();
          });
        });

        describe('on cancel', function () {
          beforeEach(function () {
            confirm.set(false);
            scope.toggleArchive(profile)
          });

          it('does not send a toggleArchive message to the profile', function () {
            expect(profile.toggleArchive).not.toHaveBeenCalled();
          });
        });
      });
    });


    // add a guardian
    describe('addGuardian(profile)', function () {
      var profile;

      beforeEach(function () {
        profile = { newGuardian: jasmine.createSpy().andReturn('guardian') };
        scope.addGuardian(profile);
      });

      it('calls newGuardian for the profile, passing _edit', function () {
        expect(profile.newGuardian).toHaveBeenCalledWith({ _edit: 'name' });
      });
    });


    // remove a guardian
    describe('removeGuardian(profile, guardian)', function () {
      var profile, guardian;

      beforeEach(function () {
        profile = { removeGuardian: jasmine.createSpy() };
        guardian = {};
      });

      describe('with parent_count > 1', function () {
        beforeEach(function () {
          guardian.parent_count = 2;
          scope.removeGuardian(profile, guardian)
        });

        it('does not call confirm', function () {
          expect(confirm).not.toHaveBeenCalled();
        });

        it('sends a removeGuardian message to the profile', function () {
          expect(profile.removeGuardian).toHaveBeenCalledWith(guardian);
        });
      });

      describe('with parent_count = 1', function () {
        beforeEach(function () {
          guardian.parent_count = 1;
        });

        describe('on confirm', function () {
          beforeEach(function () {
            scope.removeGuardian(profile, guardian)
          });

          it('does calls confirm', function () {
            expect(confirm).toHaveBeenCalled();
          });

          it('sends a removeGuardian message to the profile', function () {
            expect(profile.removeGuardian).toHaveBeenCalledWith(guardian);
          });
        });

        describe('on cancel', function () {
          beforeEach(function () {
            confirm.set(false);
            scope.removeGuardian(profile, guardian);
          });

          it('does not send a removeGuardian message to the profile', function () {
            expect(profile.removeGuardian).not.toHaveBeenCalled();
          });
        });
      });
    });
  });

  /*------------------- Profile controller ----------------------*/
  describe('ProfileCtrl', function () {
    var scope, peopleBaseCtrl, deferred, peopleInterface, location;

    beforeEach(inject(function ($rootScope, $controller, _peopleInterface_, $q, $location) {
      deferred = $q.defer();

      peopleInterface = _peopleInterface_;
      spyOn(peopleInterface, 'loadProfile').andReturn(deferred.promise);

      location = $location;
      location.url('/some/path');

      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();

      $controller('ProfileCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl
      });
    }));

    it('sets the page title', function () {
      expect(scope.pageTitle).toEqual('Profile');
    });

    it('sets profile', function () {
      expect(scope.profile).toEqual(true);
    });

    it('includes the base controller', function () {
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });

    it('loads people through the interface', function () {
      expect(peopleInterface.loadProfile).toHaveBeenCalledWith('/some/path');
    });

    it('initially has people undefined', function () {
      expect(scope.people).toBeUndefined();
    });

    describe('when the promise is resolved', function () {
      beforeEach(function () {
        deferred.resolve({
          name: 'Some name',
          people: 'people array'
        });
        scope.$apply();
      });

      it('sets people', function () {
        expect(scope.people).toEqual('people array');
      });

      it('sets the page title', function () {
        expect(scope.pageTitle).toEqual('Profile: Some name');
      });
    });

    describe('when the promise is rejected', function () {
      beforeEach(function () {
        deferred.reject();
        scope.$apply();
      });

      it('sets people to an empty array', function () {
        expect(scope.people).toEqual([]);
      });

      it('sets the page title', function () {
        expect(scope.pageTitle).toEqual('Profile: Not found');
      });
    });
  });

  /*------------------- People controllers -----------------------*/

  describe('PeopleCtrl', function () {
    var scope, peopleBaseCtrl, peopleInterface, location, deferred, Groups, searchFiltersFactory, searchFilters;

    beforeEach(inject(function ($rootScope, $controller, _peopleInterface_, $q, $location, _Groups_) {
      deferred = $q.defer();
      peopleInterface = _peopleInterface_;
      spyOn(peopleInterface, 'load').andReturn(deferred.promise);

      location = $location;
      location.url('/some/path');

      searchFilters = {
        filter: jasmine.createSpy(),
        getCurrentValues: jasmine.createSpy().andReturn({ search: 'some_val', other_filter: 'other val' })
      };
      searchFiltersFactory = jasmine.createSpy().andReturn(searchFilters);

      Groups = _Groups_;
      spyOn(Groups, 'all').andReturn('group array');

      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();

      $controller('PeopleCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
        searchFilters: searchFiltersFactory
      });
    }));

    it('sets the page title', function () {
      expect(scope.pageTitle).toEqual('People');
    });

    it('includes the base controller', function () {
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });

    it('initializes filters', function () {
      expect(searchFiltersFactory).toHaveBeenCalledWith('search', 'filter');
    });

    it('initializes current filter values to the scope', function () {
      expect(searchFilters.getCurrentValues).toHaveBeenCalled();
      expect(scope.filters).toEqualData({ search: 'some_val', other_filter: 'other val' });
    });

    it('initializes filterName to the default', function () {
      scope.$apply();
      expect(scope.filterName).toEqual('Students and teachers');
    });

    describe('when the filter value changes', function () {
      it('sets values for standard filter values', function () {
        scope.filters.filter = 'archived'
        scope.$apply();
        expect(scope.filterName).toEqual('Archived students and teachers');
        scope.filters.filter = 'students'
        scope.$apply();
        expect(scope.filterName).toEqual('Students');
        scope.filters.filter = 'teachers'
        scope.$apply();
        expect(scope.filterName).toEqual('Teachers');
        scope.filters.filter = 'mentees'
        scope.$apply();
        expect(scope.filterName).toEqual('Your mentees');
      });

      it('sets a default for an unkown filter', function () {
        scope.filters.filter = 'something'
        scope.$apply();
        expect(scope.filterName).toEqual('Students and teachers');
      });

      describe('for grooup filters', function () {
        var deferred;

        beforeEach(inject(function ($q) {
          deferred = $q.defer();
          Groups.get = jasmine.createSpy().andReturn(deferred.promise);

          scope.filters.filter = 'group-16'
          scope.$apply();
        }));

        it('calls the Groups get function', function () {
          expect(Groups.get).toHaveBeenCalledWith(16);
        });

        it('sets the value to nothing initially', function () {
          expect(scope.filterName).toEqual('');
        });

        it('sets the value to nothing for a non existant group', function () {
          deferred.reject();
          scope.$apply();
          expect(scope.filterName).toEqual('');
        });

        it('returns the group name for a group', function () {
          deferred.resolve({name: 'Some group'});
          scope.$apply();
          expect(scope.filterName).toEqual('Some group');
        });
      });
    });

    describe('doSearch()', function () {
      it('applies the search filter', function () {
        scope.doSearch('some value');
        expect(searchFilters.filter).toHaveBeenCalledWith('search', 'some value');
      });
    });

    describe('applyFilter()', function () {
      it('applies a filter', function () {
        scope.applyFilter('value');
        expect(searchFilters.filter).toHaveBeenCalledWith('filter', 'value');
      });
    });

    it('loads groups', function () {
      expect(Groups.all).toHaveBeenCalled();
      expect(scope.groups).toEqual('group array');
    });

    describe('showGroupsDialog()', function() {
      it('sets dialogs.manageGroups to true', function() {
        scope.dialogs = {}
        scope.showGroupsDialog();
        expect(scope.dialogs.manageGroups).toEqual(true);
      });
    });

    it('loads people through the interface', function () {
      expect(peopleInterface.load).toHaveBeenCalledWith('/some/path');
    });

    it('initially has people undefined', function () {
      expect(scope.people).toBeUndefined();
    });

    describe('when the promise is resolved', function () {
      var listener;

      beforeEach(function () {
        listener = jasmine.createSpy();
        scope.$on('peopleLoaded', listener);

        deferred.resolve({
          metadata: { current_page: 1, total_pages: 3 },
          people: 'people array'
        });
        scope.$apply();
      });

      it('sets people', function () {
        expect(scope.people).toEqual('people array');
      });

      it('sets the page data', function () {
        expect(scope.totalPages).toEqual(3);
        expect(scope.currentPage).toEqual(1);
      });

      it('fires a peopleLoaded event', function () {
        expect(listener).toHaveBeenCalled();
      });

      it('reloads the posts when $routeUpdate is fired', function () {
        peopleInterface.load.reset();
        scope.$broadcast('$routeUpdate');
        expect(peopleInterface.load).toHaveBeenCalledWith('/some/path');
      });
    });

    describe('when the promise is rejected', function () {
      beforeEach(function () {
        deferred.reject();
        scope.$apply();
      });

      it('leaves people as it is', function () {
        expect(scope.people).toBeUndefined();
      });
    });

    describe('addTeacher()', function () {
      beforeEach(function () {
        scope.people = [1, 2, 3];
        spyOn(peopleInterface, 'addTeacher').andReturn(6);
      });

      describe('with no filters', function () {
        beforeEach(function () {
          scope.addTeacher();
        });

        it('adds a teacher through peopleInterface', function () {
          expect(peopleInterface.addTeacher).toHaveBeenCalledWith({ _edit: 'name' });
        });

        it('adds the result to the people array', function () {
          expect(scope.people).toEqual([6, 1, 2, 3]);
        });
      });

      describe('with filters', function () {
        beforeEach(function () {
          location.search({param: 'value'});
          scope.addTeacher();
        });

        it('clears any parameters', function () {
          expect(location.search()).toEqual({});
        });

        describe('after a peopleLoaded event', function () {
          beforeEach(function () {
            scope.$broadcast('peopleLoaded');
          });

          it('adds a teacher through peopleInterface', function () {
            expect(peopleInterface.addTeacher).toHaveBeenCalledWith({ _edit: 'name' });
          });

          it('adds the result to the people array', function () {
            expect(scope.people).toEqual([6, 1, 2, 3]);
          });
        });
      });
    });

    describe('addStudent()', function () {
      beforeEach(function () {
        scope.people = [1, 2, 3];
        spyOn(peopleInterface, 'addStudent').andReturn(7);
      });

      describe('with no filters', function () {
        beforeEach(function () {
          scope.addStudent();
        });

        it('adds a teacher through peopleInterface', function () {
          expect(peopleInterface.addStudent).toHaveBeenCalledWith({ _edit: 'name' });
        });

        it('adds the result to the people array', function () {
          expect(scope.people).toEqual([7, 1, 2, 3]);
        });
      });

      describe('with filters', function () {
        beforeEach(function () {
          location.search({param: 'value'});
          scope.addStudent();
        });

        it('clears any parameters', function () {
          expect(location.search()).toEqual({});
        });

        describe('after a peopleLoaded event', function () {
          beforeEach(function () {
            scope.$broadcast('peopleLoaded');
          });

          it('adds a teacher through peopleInterface', function () {
            expect(peopleInterface.addStudent).toHaveBeenCalledWith({ _edit: 'name' });
          });

          it('adds the result to the people array', function () {
            expect(scope.people).toEqual([7, 1, 2, 3]);
          });
        });
      });
    });
  });
});