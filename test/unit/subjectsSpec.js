'use strict';

describe('subjects module', function () {
  beforeEach(module('journals.subjects'));

  /*------------------ Subjects collection ----------------------*/
  describe('Subjects', function() {
    var collection, model, Subjects;

    beforeEach(module(function($provide) {
      model = jasmine.createSpy().andReturn('model');
      collection = jasmine.createSpy().andReturn('collection');
      $provide.value('model', model);
      $provide.value('collection', collection);
    }));

    beforeEach(inject(function(_Subjects_) {
      Subjects = _Subjects_;
    }));

    it('sets the model name', function() {
      expect(model.mostRecentCall.args[0]).toEqual('subject');
    });

    it('sets the model url', function() {
      expect(model.mostRecentCall.args[1]).toEqual('/academics/subjects');
    });

    it('calls the collection with the model object', function() {
      expect(collection).toHaveBeenCalledWith('model');
    });

    it('returns the collection object', function() {
      expect(Subjects).toEqual('collection');
    });
  });


  /*------------------ Subjects controller ----------------------*/
  describe('SubjectsCtrl', function () {
    var scope, httpBackend, Subjects, confirm, frameworkService, subjectPeopleService;

    beforeEach(inject(function ($rootScope, $httpBackend, $controller, _confirm_) {
      confirm = _confirm_;
      scope = $rootScope.$new();
      httpBackend = $httpBackend;
      frameworkService = { showFramework: jasmine.createSpy() };
      subjectPeopleService = { show: jasmine.createSpy() };

      Subjects = { all: jasmine.createSpy('Subjects.all').
        andReturn([{id: 1, name: 'One'}, {id: 3, name: 'Three'}]) };

      $controller('SubjectsCtrl', {
        $scope: scope,
        Subjects: Subjects,
        frameworkService: frameworkService,
        subjectPeopleService: subjectPeopleService
      });
    }));

    it('sets pageTitle', function () {
      expect(scope.pageTitle).toEqual('Academic records');
    });

    it('sets subjects to the value of Subjects.all()', function() {
      expect(Subjects.all).toHaveBeenCalled();
      expect(scope.subjects).toEqual([{id: 1, name: 'One'}, {id: 3, name: 'Three'}]);
    });

    describe('add()', function() {
      beforeEach(function() {
        Subjects.add = jasmine.createSpy('Subjects.add').andReturn('subject');
        scope.add('test');
      });

      it('adds alls Subjects.add()', function() {
        expect(Subjects.add).toHaveBeenCalled();
      });

      it('sets _edit to name for the new object', function() {
        expect(Subjects.add.mostRecentCall.args[0]).toEqual({ _edit: 'name' });
      });
    });

    describe('edit(subject)', function() {
      it('changes the location framework parameter', inject(function ($location) {
        scope.edit({id: 7});
        expect($location.search().framework).toEqual(7);
      }));
    });

    describe('showPeople(subject)', function() {
      it('triggers the show people service', function () {
        scope.showPeople('subject');
        expect(subjectPeopleService.show).toHaveBeenCalledWith('subject');
      });
    });

    describe('on a route update', function () {
      describe('with a framework param set', function () {
        beforeEach(inject(function ($location) {
          $location.search('framework', 16);
          scope.$broadcast('$routeUpdate');
        }));

        it('triggers the framework service', function () {
          expect(frameworkService.showFramework).toHaveBeenCalledWith(16);
        });
      });

      describe('without a framework param set', function () {
        beforeEach(inject(function ($location) {
          scope.$broadcast('$routeUpdate');
        }));

        it('does not trigger the framework service', function () {
          expect(frameworkService.showFramework).not.toHaveBeenCalled();
        });
      });
    });

    describe('delete(subject)', function () {
      var subject;

      beforeEach(function() {
        subject = { delete: jasmine.createSpy() };
      });

      describe('on confirm', function () {
        beforeEach(function () {
          scope.delete(subject)
        });

        it('sends a delete message to the subject', function () {
          expect(subject.delete).toHaveBeenCalled();
        });
      });

      describe('on cancel', function () {
        beforeEach(function () {
          confirm.set(false);
          scope.delete(subject)
        });

        it('does not send a delete message to the subject', function () {
          expect(subject.delete).not.toHaveBeenCalled();
        });
      });
    });
  });

  /*------------------ Framework service -----------------------*/
  describe('frameworkService', function () {
    var frameworkService, scope;

    beforeEach(inject(function (_frameworkService_) {
      frameworkService = _frameworkService_;
      scope = { show: jasmine.createSpy() };
      frameworkService.register(scope);
    }));

    describe('showFramework(subjectId)', function () {
      it('calls the scopes show function, passing the argument', function () {
        expect(scope.show).not.toHaveBeenCalled();
        frameworkService.showFramework('some subject id');
        expect(scope.show).toHaveBeenCalledWith('some subject id');
      });
    });
  });

  /*-------------------- Framework Controller -------------------------*/
   describe('FrameworkCtrl', function () {
    var scope, httpBackend, frameworkService, Framework, confirm;

    beforeEach(inject(function ($rootScope, $httpBackend, $controller, _confirm_) {
      confirm = _confirm_;
      scope = $rootScope.$new();
      httpBackend = $httpBackend;
      frameworkService = { register: jasmine.createSpy() };
      Framework = { create: jasmine.createSpy().andReturn('some framework model data') }

      $controller('FrameworkCtrl', { $scope: scope, frameworkService: frameworkService, Framework: Framework });
    }));

    it('registers the frameworkService', function () {
      expect(frameworkService.register).toHaveBeenCalledWith(scope);
    });

    it('sets shown to false initially', function () {
      expect(scope.shown).toEqual(false);
    });

    describe('show()', function () {
      beforeEach(function () {
        httpBackend.expectGET('/academics/subjects/8.json').respond('some subject data')

        scope.show(8);
      });

      it('sets shown to true', function () {
        expect(scope.shown).toEqual(true);
      });

      it('sets the subject data to null', function () {
        expect(scope.framework).toBeNull();
      });

      it('sends a request for subject data', function () {
        httpBackend.verifyNoOutstandingExpectation();
      });

      describe('on response', function () {
        beforeEach(function () {
          httpBackend.flush();
        });

        it('creates a model', function () {
          expect(Framework.create).toHaveBeenCalledWith('some subject data');
        });

        it('sets the framework data', function () {
          expect(scope.framework).toEqual('some framework model data');
        });
      });

      describe('on failure', function () {
        beforeEach(function () {
          httpBackend.resetExpectations();
          httpBackend.expectGET('/academics/subjects/8.json').respond(400)
          httpBackend.flush();
        });

        it('sets shown to false', function () {
          expect(scope.shown).toEqual(false);
        });
      });
    });

    describe('close()', function () {
      var location;

      beforeEach(inject(function ($location) {
        location = $location;
        location.search('framework', 2);
        scope.shown = true;
        scope.close();
      }));

      it('sets shown to false', function () {
        expect(scope.shown).toEqual(false);
      });

      it('removes the framework param', function () {
        expect(location.search().framework).toBeUndefined();
      });
    });

    describe('deleteMilestone(milestone)', function () {
      var milestone;

      beforeEach(function() {
        milestone = { delete: jasmine.createSpy() };
      });

      describe('on confirm', function () {
        beforeEach(function () {
          scope.deleteMilestone(milestone)
        });

        it('sends a delete message to the milestone', function () {
          expect(milestone.delete).toHaveBeenCalled();
        });
      });

      describe('on cancel', function () {
        beforeEach(function () {
          confirm.set(false);
          scope.deleteMilestone(milestone)
        });

        it('does not send a delete message to the milestone', function () {
          expect(milestone.delete).not.toHaveBeenCalled();
        });
      });
    });

    describe('deleteStrand(strand)', function () {
      var strand;

      beforeEach(function() {
        strand = { delete: jasmine.createSpy() };
      });

      describe('on confirm', function () {
        beforeEach(function () {
          scope.deleteStrand(strand)
        });

        it('sends a delete message to the strand', function () {
          expect(strand.delete).toHaveBeenCalled();
        });
      });

      describe('on cancel', function () {
        beforeEach(function () {
          confirm.set(false);
          scope.deleteStrand(strand)
        });

        it('does not send a delete message to the strand', function () {
          expect(strand.delete).not.toHaveBeenCalled();
        });
      });
    });

    describe('addMilestone(level, strand)', function() {
      var strand;

      beforeEach(function() {
        strand = { newMilestone: jasmine.createSpy().andReturn('milestone') };
        scope.addMilestone(2, strand);
      });

      it('adds the milestone to the strand', function() {
        expect(strand.newMilestone).toHaveBeenCalledWith({_edit: 'content', level: 2});
      });
    });
  });

  /*------------------ Subject People service -----------------------*/
  describe('subjectPeopleService', function () {
    var subjectPeopleService, scope;

    beforeEach(inject(function (_subjectPeopleService_) {
      subjectPeopleService = _subjectPeopleService_;
      scope = { show: jasmine.createSpy() };
      subjectPeopleService.register(scope);
    }));

    describe('show(subject)', function () {
      it('calls the scopes show function, passing the argument', function () {
        expect(scope.show).not.toHaveBeenCalled();
        subjectPeopleService.show('some subject');
        expect(scope.show).toHaveBeenCalledWith('some subject');
      });
    });
  });

  /*-------------------- SubjectPeople Controller -------------------------*/
   describe('SubjectPeopleCtrl', function () {
    var scope, httpBackend, subjectPeopleService, SubjectPeople;

    beforeEach(inject(function ($rootScope, $httpBackend, $controller) {
      scope = $rootScope.$new();
      httpBackend = $httpBackend;
      subjectPeopleService = { register: jasmine.createSpy() };
      SubjectPeople = { create: jasmine.createSpy().andReturn('model data') };

      $controller('SubjectPeopleCtrl', {
        $scope: scope,
        subjectPeopleService: subjectPeopleService,
        SubjectPeople: SubjectPeople
      });
    }));

    it('registers the subjectPeopleService', function () {
      expect(subjectPeopleService.register).toHaveBeenCalledWith(scope);
    });

    it('dialog shown is initially undefined', function () {
      expect(scope.dialog.shown).toBeUndefined();
    });

    describe('show()', function () {
      beforeEach(function () {
        httpBackend.expectGET('/some/path/people.json').respond('subject data')
        scope.show({ url: function () { return '/some/path' } });
      });

      it('sets dialog shown to true', function () {
        expect(scope.dialog.shown).toEqual(true);
      });

      it('clears subjectPeople', function () {
        expect(scope.subjectPeople).toBeNull();
      });

      it('clears selected', function () {
        expect(scope.selected).toBeNull();
      });

      it('sends a http request', function () {
        httpBackend.verifyNoOutstandingExpectation();
      });

      describe('on response', function () {
        beforeEach(function () {
          httpBackend.flush();
        });

        it('creates a model', function () {
          expect(SubjectPeople.create).toHaveBeenCalledWith('subject data');
        });

        it('sets the subject people data', function () {
          expect(scope.subjectPeople).toEqual('model data');
        });
      });

      describe('on failure', function () {
        beforeEach(function () {
          httpBackend.resetExpectations();
          httpBackend.expectGET('/some/path/people.json').respond(400)
          httpBackend.flush();
        });

        it('sets dialog shown to false', function () {
          expect(scope.dialog.shown).toEqual(false);
        });
      });
    });

    describe('deleteTeacher(subject_teacher)', function () {
      beforeEach(function() {
        scope.subjectPeople = { removeSubjectTeacher: jasmine.createSpy() };
      });

      it('removes the subject teacher', function () {
        scope.deleteTeacher('some subject teacher');
        expect(scope.subjectPeople.removeSubjectTeacher).toHaveBeenCalledWith('some subject teacher');
      });

      describe('with the removed teacher selected', function () {
        beforeEach(function () {
          scope.selected = 'some subject teacher';
        });

        it('clears selected', function () {
          scope.deleteTeacher('some subject teacher');
          expect(scope.selected).toBeNull();
        });
      });

      describe('with another teacher selected', function () {
        beforeEach(function () {
          scope.selected = 'some other subject teacher';
        });

        it('does not clear selected', function () {
          scope.deleteTeacher('some subject teacher');
          expect(scope.selected).toEqual('some other subject teacher');
        });
      });
    });

    describe('addTeacher(teacher)', function () {
      var subjectTeacher;

      beforeEach(function() {
        subjectTeacher = { save: jasmine.createSpy() };
        scope.subjectPeople = { newSubjectTeacher: jasmine.createSpy().andReturn(subjectTeacher) };
        scope.addTeacher('some teacher');
      });

      it('adds a new subject teacher', function () {
        expect(scope.subjectPeople.newSubjectTeacher).toHaveBeenCalledWith({teacher: 'some teacher'});
      });

      it('saves the subject teacher', function () {
        expect(subjectTeacher.save).toHaveBeenCalled();
      });

      it('sets selected', function () {
        expect(scope.selected).toEqual(subjectTeacher);
      });
    });

    describe('selectTeacher(subject_teacher)', function () {
      beforeEach(function() {
        scope.selectTeacher('some subject teacher');
      });

      it('sets selected', function () {
        expect(scope.selected).toEqual('some subject teacher');
      });
    });
  });
});