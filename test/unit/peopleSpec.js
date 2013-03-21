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

    it('loads data initially', function () {
      expect(scope.load).toHaveBeenCalled();
    });

    it('reloads data on a route update', function () {
      scope.load.reset();
      scope.$broadcast('$routeUpdate');
      expect(scope.load).toHaveBeenCalled();
    });

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

  /*------------------ people collection mixin -----------------*/

  describe('peopleCollectionMixin', function () {
    var scope, peopleInterface, location, deferred, Groups;

    beforeEach(inject(function ($rootScope, peopleBaseCtrl, _peopleInterface_, $q, $location, peopleCollectionMixin, _Groups_) {
      deferred = $q.defer();

      peopleInterface = _peopleInterface_;
      spyOn(peopleInterface, 'load').andReturn(deferred.promise);

      location = $location;
      location.url('/some/path');

      Groups = _Groups_;
      spyOn(Groups, 'all').andReturn('group array');

      scope = $rootScope.$new();
      peopleCollectionMixin(scope);
    }));

    it('sets the scope search to the location search value', inject(function($rootScope, peopleCollectionMixin) {
      location.url('/some/path?search=blah');
      scope = $rootScope.$new();
      peopleCollectionMixin(scope);
      expect(scope.search).toEqual('blah');
    }));

    describe('doSearch()', function () {
      it('updates the location param', function () {
        scope.doSearch('some value');
        expect(location.search().search).toEqual('some value');
      });

      it('resets the page param', function () {
        location.search('page', 2);
        scope.doSearch('some value');
        expect(location.search().page).toBeUndefined();
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

    describe('scope.load()', function () {
      beforeEach(function () {
        scope.load();
      });

      it('loads people through the interface', function () {
        expect(peopleInterface.load).toHaveBeenCalledWith('/some/path');
      });

      it('initially has people undefined', function () {
        expect(scope.people).toBeUndefined();
      });

      describe('when the promise is resolved', function () {
        beforeEach(function () {
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
    });

    describe('addTeacher()', function () {
      beforeEach(function () {
        scope.people = [1, 2, 3];
        spyOn(peopleInterface, 'addTeacher').andReturn(6);
        scope.addTeacher();
      });

      it('adds a teacher through peopleInterface', function () {
        expect(peopleInterface.addTeacher).toHaveBeenCalledWith({ _edit: 'name' });
      });

      it('adds the result to the people array', function () {
        expect(scope.people).toEqual([6, 1, 2, 3]);
      });
    });

    describe('addStudent()', function () {
      beforeEach(function () {
        scope.people = [1, 2, 3];
        spyOn(peopleInterface, 'addStudent').andReturn(7);
        scope.addStudent();
      });

      it('adds a teacher through peopleInterface', function () {
        expect(peopleInterface.addStudent).toHaveBeenCalledWith({ _edit: 'name' });
      });

      it('adds the result to the people array', function () {
        expect(scope.people).toEqual([7, 1, 2, 3]);
      });
    });
  });

  /*------------------ Load profile service -----------------*/

  describe('loadProfile', function () {
    var scope, peopleInterface, location, deferred;

    beforeEach(inject(function ($rootScope, peopleBaseCtrl, _peopleInterface_, $q, $location, loadProfile) {
      deferred = $q.defer();

      peopleInterface = _peopleInterface_;
      spyOn(peopleInterface, 'loadProfile').andReturn(deferred.promise);

      location = $location;
      location.url('/some/path');

      scope = $rootScope.$new();
      loadProfile(scope);
    }));

    describe('scope.load()', function () {
      beforeEach(function () {
        scope.load();
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
  });

  /*------------------- Profile controller ----------------------*/
  describe('ProfileCtrl', function () {
    var scope, peopleBaseCtrl, loadProfile;

    beforeEach(inject(function ($rootScope, $controller) {
      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();
      loadProfile = jasmine.createSpy();

      $controller('ProfileCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
        loadProfile: loadProfile
      });
    }));

    it('sets the page title', function () {
      expect(scope.pageTitle).toEqual('Profile');
    });

    it('sets profile', function () {
      expect(scope.profile).toEqual(true);
    });

    it('includes loadProfile', function () {
      expect(loadProfile).toHaveBeenCalledWith(scope);
    });

    it('includes the base controller', function () {
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  /*------------------- People controllers -----------------------*/

  describe('PeopleCtrl', function () {
    var scope, peopleBaseCtrl, peopleCollectionMixin;

    beforeEach(inject(function ($rootScope, $controller) {
      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();
      peopleCollectionMixin = jasmine.createSpy();

      $controller('PeopleCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
        peopleCollectionMixin: peopleCollectionMixin
      });
    }));

    it('sets the page title', function () {
      expect(scope.pageTitle).toEqual('People');
    });

    it('sets canAddStudent', function () {
      expect(scope.canAddStudent).toEqual(true);
    });

    it('sets canAddTeacher', function () {
      expect(scope.canAddTeacher).toEqual(true);
    });

    it('sets the filterName', function () {
      expect(scope.filterName).toEqual('Students and teachers');
    });

    it('includes peopleCollectionMixin', function () {
      expect(peopleCollectionMixin).toHaveBeenCalledWith(scope);
    });

    it('includes the base controller', function () {
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  describe('ArchivedPeopleCtrl', function () {
    var scope, peopleBaseCtrl, peopleCollectionMixin;

    beforeEach(inject(function ($rootScope, $controller) {
      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();
      peopleCollectionMixin = jasmine.createSpy();

      $controller('ArchivedPeopleCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
        peopleCollectionMixin: peopleCollectionMixin
      });
    }));

    it('sets the page title', function () {
      expect(scope.pageTitle).toEqual('Archive');
    });

    it('sets canAddStudent', function () {
      expect(scope.canAddStudent).toEqual(false);
    });

    it('sets canAddTeacher', function () {
      expect(scope.canAddTeacher).toEqual(false);
    });

    it('sets the filterName', function () {
      expect(scope.filterName).toEqual('Archived students and teachers');
    });

    it('includes peopleCollectionMixin', function () {
      expect(peopleCollectionMixin).toHaveBeenCalledWith(scope);
    });

    it('includes the base controller', function () {
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  describe('TeachersCtrl', function () {
    var scope, peopleBaseCtrl, peopleCollectionMixin;

    beforeEach(inject(function ($rootScope, $controller) {
      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();
      peopleCollectionMixin = jasmine.createSpy();

      $controller('TeachersCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
        peopleCollectionMixin: peopleCollectionMixin
      });
    }));

    it('sets the page title', function () {
      expect(scope.pageTitle).toEqual('Teachers');
    });

    it('sets canAddStudent', function () {
      expect(scope.canAddStudent).toEqual(false);
    });

    it('sets canAddTeacher', function () {
      expect(scope.canAddTeacher).toEqual(true);
    });

    it('sets the filterName', function () {
      expect(scope.filterName).toEqual('Teachers');
    });

    it('includes peopleCollectionMixin', function () {
      expect(peopleCollectionMixin).toHaveBeenCalledWith(scope);
    });

    it('includes the base controller', function () {
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  describe('StudentsCtrl', function () {
    var scope, peopleBaseCtrl, peopleCollectionMixin;

    beforeEach(inject(function ($rootScope, $controller) {
      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();
      peopleCollectionMixin = jasmine.createSpy();

      $controller('StudentsCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
        peopleCollectionMixin: peopleCollectionMixin
      });
    }));

    it('sets the page title', function () {
      expect(scope.pageTitle).toEqual('Students');
    });

    it('sets canAddStudent', function () {
      expect(scope.canAddStudent).toEqual(true);
    });

    it('sets canAddTeacher', function () {
      expect(scope.canAddTeacher).toEqual(false);
    });

    it('sets the filterName', function () {
      expect(scope.filterName).toEqual('Students');
    });

    it('includes peopleCollectionMixin', function () {
      expect(peopleCollectionMixin).toHaveBeenCalledWith(scope);
    });

    it('includes the base controller', function () {
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  describe('MenteesCtrl', function () {
    var scope, peopleBaseCtrl, peopleCollectionMixin;

    beforeEach(inject(function ($rootScope, $controller) {
      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();
      peopleCollectionMixin = jasmine.createSpy();

      $controller('MenteesCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
        peopleCollectionMixin: peopleCollectionMixin
      });
    }));

    it('sets the page title', function () {
      expect(scope.pageTitle).toEqual('Mentees');
    });

    it('sets canAddStudent', function () {
      expect(scope.canAddStudent).toEqual(false);
    });

    it('sets canAddTeacher', function () {
      expect(scope.canAddTeacher).toEqual(false);
    });

    it('sets the filterName', function () {
      expect(scope.filterName).toEqual('Your mentees');
    });

    it('includes peopleCollectionMixin', function () {
      expect(peopleCollectionMixin).toHaveBeenCalledWith(scope);
    });

    it('includes the base controller', function () {
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });

  /*--------------- GroupsPage controller --------------------*/

  describe('GroupsPageCtrl', function () {
    var scope, peopleBaseCtrl, peopleCollectionMixin, Groups, deferred;

    beforeEach(inject(function ($rootScope, $controller, _Groups_, $q) {
      scope = $rootScope.$new();
      peopleBaseCtrl = jasmine.createSpy();
      peopleCollectionMixin = jasmine.createSpy();

      deferred = $q.defer();
      Groups = _Groups_;
      spyOn(Groups, 'get').andReturn(deferred.promise)

      $controller('GroupsPageCtrl', {
        $scope: scope,
        peopleBaseCtrl: peopleBaseCtrl,
        peopleCollectionMixin: peopleCollectionMixin,
        $routeParams: { id: '4' }
      });
    }));

    it('sets the page title', function () {
      expect(scope.pageTitle).toEqual('Group');
    });

    it('sets the filterName', function () {
      expect(scope.filterName).toEqual('Group');
    });

    it('gets the group from the Groups collection', function () {
      expect(Groups.get).toHaveBeenCalledWith(4);
    });

    describe('when the group is found', function () {
      beforeEach(function () {
        deferred.resolve({id: 4, name: 'Some group'});
        scope.$apply();
      });

      it('sets the page title', function () {
        expect(scope.pageTitle).toEqual('Group: Some group');
      });

      it('sets the filterName', function () {
        expect(scope.filterName).toEqual('Some group');
      });
    });

    describe('when the group is not found', function () {
      beforeEach(function () {
        deferred.reject();
        scope.$apply();
      });

      it('sets the page title', function () {
        expect(scope.pageTitle).toEqual('Group: Not found');
      });

      it('sets the filterName', function () {
        expect(scope.filterName).toEqual('Unknown group');
      });
    });

    it('sets canAddStudent', function () {
      expect(scope.canAddStudent).toEqual(false);
    });

    it('sets canAddTeacher', function () {
      expect(scope.canAddTeacher).toEqual(false);
    });

    it('includes peopleCollectionMixin', function () {
      expect(peopleCollectionMixin).toHaveBeenCalledWith(scope);
    });

    it('includes the base controller', function () {
      expect(peopleBaseCtrl).toHaveBeenCalledWith(scope);
    });
  });
});