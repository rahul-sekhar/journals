'use strict';

describe('posts module', function () {
  beforeEach(module('journals.posts'));

  /*------------------- Posts controller ------------------*/

  describe('PostsCtrl', function () {
    var scope, httpBackend, controller, Posts, location,
      searchFiltersFactory, searchFilters, Students, Groups, Tags;

    beforeEach(inject(function ($rootScope, $httpBackend, $controller, _Posts_, $location) {
      httpBackend = $httpBackend;

      scope = $rootScope.$new();
      controller = $controller;

      Posts = _Posts_;
      location = $location;

      location.url('/path/to/posts')
      spyOn(Posts, 'update').andCallFake(function (data) {
        return 'post instance ' + data.id;
      });

      searchFilters = {
        filter: jasmine.createSpy(),
        getCurrentValues: jasmine.createSpy().andReturn({ search: 'some_val', other_filter: 'other val' })
      };
      searchFiltersFactory = jasmine.createSpy().andReturn(searchFilters);

      Students = { all: jasmine.createSpy().andReturn('student list') };
      Groups = { all: jasmine.createSpy().andReturn('group list') };
      Tags = { all: jasmine.createSpy().andReturn('tag list') };

      // helpPost = { setStep: jasmine.createSpy() }
      // createHelpPost = jasmine.createSpy().andReturn(helpPost);
    }));

    describe('on success', function () {
      beforeEach(function () {
        httpBackend.expectGET('/path/to/posts.json').respond({
          current_page: 2,
          total_pages: 4,
          items: [{ id: 1, title: 'Some post' }, {id: 2}, {id: 7}]
        });
        controller('PostsCtrl', {
          $scope: scope,
          // createHelpPost: createHelpPost,
          searchFilters: searchFiltersFactory,
          Students: Students,
          Groups: Groups,
          Tags: Tags
        });
      });

      it('sends a request', function () {
        httpBackend.verifyNoOutstandingExpectation();
      });

      it('initially has posts undefined', function () {
        expect(scope.posts).toBeUndefined();
      });

      it('has pageTitle set', function () {
        expect(scope.pageTitle).toEqual('Viewing posts')
      });

      it('does not set single_post', function () {
        expect(scope.single_post).toBeUndefined();
      });

      it('sets the scope search value to undefined', function () {
        expect(scope.search).toBeUndefined();
      });

      describe('hideMenus()', function () {
        var childScope, listener;

        beforeEach(function () {
          childScope = scope.$new();
          listener = jasmine.createSpy();
          childScope.$on('hideMenus', listener);
          scope.hideMenus();
        });

        it('broadcasts a hideMenus event', function () {
          expect(listener).toHaveBeenCalled();
        });

        it('passes an empty array with the event', function () {
          expect(listener.mostRecentCall.args[1]).toEqual([]);
        });
      });

      // describe('helpPost', function () {
      //   it('creates a help post instance', function () {
      //     expect(createHelpPost).toHaveBeenCalled();
      //     expect(scope.helpPost).toBe(helpPost);
      //   });

      //   it('sets the helpPost step to 1 when help is shown', function () {
      //     expect(helpPost.setStep).not.toHaveBeenCalled();
      //     scope.help.shown = true;
      //     scope.$apply();
      //     expect(helpPost.setStep).toHaveBeenCalledWith(1);
      //   });
      // });

      describe('filters', function () {
        it('initializes filters', function () {
          expect(searchFiltersFactory).toHaveBeenCalledWith(['search', 'student', 'group', 'tag', 'dateFrom', 'dateTo']);
        });

        it('initializes current filter values to the scope', function () {
          expect(searchFilters.getCurrentValues).toHaveBeenCalled();
          expect(scope.filters).toEqualData({ search: 'some_val', other_filter: 'other val' });
        });

        it('initializes students', function () {
          expect(Students.all).toHaveBeenCalled();
          expect(scope.students).toEqual('student list');
        });

        it('initializes groups', function () {
          expect(Groups.all).toHaveBeenCalled();
          expect(scope.groups).toEqual('group list');
        });

        it('initializes tags', function () {
          expect(Tags.all).toHaveBeenCalled();
          expect(scope.tags).toEqual('tag list');
        });

        describe('filter(filter, val)', function () {
          it('applies a filter', function () {
            scope.filter('some filter', 'some value');
            expect(searchFilters.filter).toHaveBeenCalledWith('some filter', 'some value');
          });
        });

        describe('studentName', function () {
          beforeEach(inject(function ($q) {
            Students.get = jasmine.createSpy().andReturn($q.when({name: 'name'}));
          }));

          it('is initialized to all students', function () {
            scope.$apply();
            expect(scope.studentName).toEqual('All students');
          });

          it('is set to all students with the filter set to null', function () {
            scope.filters.student = null;
            scope.$apply();
            expect(scope.studentName).toEqual('All students');
            expect(Students.get).not.toHaveBeenCalled();
          });

          it('is set to the student name', function () {
            scope.filters.student = 4;
            scope.$apply();
            expect(scope.studentName).toEqual('name');
            expect(Students.get).toHaveBeenCalledWith(4);
          });
        });

        describe('filterStudent(student)', function () {
          it('removes a group filter if present', function () {
            location.search('group', 5);
            scope.filterStudent({id: 5});
            expect(location.search().group).toBeUndefined();
          });

          it('applies a student filter', function () {
            scope.filterStudent({id: 5});
            expect(searchFilters.filter).toHaveBeenCalledWith('student', 5);
          });

          it('clears a student filter', function () {
            scope.filterStudent(null);
            expect(searchFilters.filter).toHaveBeenCalledWith('student', null);
          });
        });

        describe('groupName', function () {
          beforeEach(inject(function ($q) {
            Groups.get = jasmine.createSpy().andReturn($q.when({name: 'name'}));
          }));

          it('is initialized to all groups', function () {
            scope.$apply();
            expect(scope.groupName).toEqual('All groups');
          });

          it('is set to all groups with the filter set to null', function () {
            scope.filters.group = null;
            scope.$apply();
            expect(scope.groupName).toEqual('All groups');
            expect(Groups.get).not.toHaveBeenCalled();
          });

          it('is set to the group name', function () {
            scope.filters.group = 4;
            scope.$apply();
            expect(scope.groupName).toEqual('name');
            expect(Groups.get).toHaveBeenCalledWith(4);
          });
        });

        describe('filterGroup(group)', function () {
          it('removes a student filter if present', function () {
            location.search('student', 5);
            scope.filterGroup({id: 5});
            expect(location.search().student).toBeUndefined();
          });

          it('applies a group filter', function () {
            scope.filterGroup({id: 5});
            expect(searchFilters.filter).toHaveBeenCalledWith('group', 5);
          });

          it('clears a group filter', function () {
            scope.filterGroup(null);
            expect(searchFilters.filter).toHaveBeenCalledWith('group', null);
          });
        });

        describe('tagName', function () {
          beforeEach(inject(function ($q) {
            Tags.get = jasmine.createSpy().andReturn($q.when({name: 'name'}));
          }));

          it('is initialized to all tags', function () {
            scope.$apply();
            expect(scope.tagName).toEqual('All tags');
          });

          it('is set to all tags with the filter set to null', function () {
            scope.filters.tag = null;
            scope.$apply();
            expect(scope.tagName).toEqual('All tags');
            expect(Tags.get).not.toHaveBeenCalled();
          });

          it('is set to the tag name', function () {
            scope.filters.tag = 4;
            scope.$apply();
            expect(scope.tagName).toEqual('name');
            expect(Tags.get).toHaveBeenCalledWith(4);
          });
        });
      });

      describe('on response', function () {
        beforeEach(function () {
          httpBackend.flush();
        });

        it('updates the Posts collection with the recieved data', function() {
          expect(Posts.update.callCount).toEqual(3);
          expect(Posts.update.argsForCall[0][0]).toEqual({ id: 1, title: 'Some post' })
          expect(Posts.update.argsForCall[1][0]).toEqual({ id: 2 })
          expect(Posts.update.argsForCall[2][0]).toEqual({ id: 7 })
        });

        it('sets posts to the post instances', function () {
          expect(scope.posts).toEqual(['post instance 1', 'post instance 2', 'post instance 7']);
        });

        it('sets currentPage', function () {
          expect(scope.currentPage).toEqual(2);
        });

        it('sets totalPages', function () {
          expect(scope.totalPages).toEqual(4);
        });

        it('reloads the posts when $routeUpdate is fired', function () {
          httpBackend.expectGET('/path/to/posts.json').respond(200);
          scope.$broadcast('$routeUpdate');
          httpBackend.verifyNoOutstandingExpectation();
        });
      });
    });

    describe('on failure', function () {
      beforeEach(function () {
        httpBackend.expectGET('/path/to/posts.json').respond(400);
        controller('PostsCtrl', {
          $scope: scope,
          // createHelpPost: createHelpPost,
          searchFilters: searchFiltersFactory,
          Students: Students,
          Groups: Groups,
          Tags: Tags
        });
        httpBackend.flush();
      });

      it('sets posts to an empty array', function () {
        expect(scope.posts).toEqual([]);
      });

      it('sets currentPage to null', function () {
        expect(scope.currentPage).toBeNull();
      });

      it('sets totalPages to null', function () {
        expect(scope.totalPages).toBeNull();
      });
    });
  });



  /*------------------- Single post controller ------------------*/

  describe('ViewPostCtrl', function () {
    var scope, httpBackend, controller, Posts;

    beforeEach(inject(function ($rootScope, $httpBackend, $controller, _Posts_) {
      httpBackend = $httpBackend;

      scope = $rootScope.$new();
      controller = $controller;

      Posts = _Posts_;
      spyOn(Posts, 'update').andCallFake(function(data) {
        return 'post instance ' + data.id;
      });
    }));

    describe('on success', function () {
      beforeEach(function () {
        httpBackend.expectGET('/posts/5.json').respond({ id: 1, title: 'Some post' });
        controller('ViewPostCtrl', { $scope: scope, $routeParams: { id: 5 } });
      });

      it('sends a request', function () {
        httpBackend.verifyNoOutstandingExpectation();
      });

      it('initially has posts undefined', function () {
        expect(scope.posts).toBeUndefined();
      });

      it('has pageTitle set', function () {
        expect(scope.pageTitle).toEqual('Viewing a post');
      });

      it('sets single_post', function () {
        expect(scope.single_post).toEqual(true);
      });

      describe('on response', function () {
        beforeEach(function () {
          httpBackend.flush();
        });

        it('updates the Posts collection with the recieved data', function() {
          expect(Posts.update).toHaveBeenCalledWith({ id: 1, title: 'Some post' })
        });

        it('sets posts to the post instance', function () {
          expect(scope.posts).toEqual(['post instance 1']);
        });

        it('leaves pageTitle unchanged', function () {
          expect(scope.pageTitle).toEqual('Viewing a post');
        });
      });
    });

    describe('on failure', function () {
      beforeEach(function () {
        httpBackend.expectGET('/posts/5.json').respond(404);
        controller('ViewPostCtrl', { $scope: scope, $routeParams: { id: 5 } });
        httpBackend.flush();
      });

      it('sets posts to an empty array', function () {
        expect(scope.posts).toEqual([]);
      });

      it('changes pageTitle', function () {
        expect(scope.pageTitle).toEqual('Post not found');
      });
    });
  });


  /*------------------------ Edit post controller ------------------------*/


  describe('EditPostCtrl', function () {
    var scope, httpBackend, controller, Posts, confirm, User;

    beforeEach(module(function ($provide) {
      User = { type: 'Teacher', id: 76 };
      $provide.value('User', User);
    }));

    beforeEach(inject(function ($rootScope, $httpBackend, $controller, _Posts_, _confirm_, $q) {
      User.promise = $q.when();
      httpBackend = $httpBackend;
      scope = $rootScope.$new();
      controller = $controller;
      Posts = _Posts_;
      confirm = _confirm_;
    }));

    describe('with no route id', function () {
      beforeEach(function () {
        spyOn(Posts, 'add').andReturn('new post');
      });

      describe('with a teacher logged in', function () {
        beforeEach(function () {
          controller('EditPostCtrl', { $scope: scope });
          scope.$apply();
        });

        it('sets pageTitle', function () {
          expect(scope.pageTitle).toEqual('Create a post');
        })

        it('adds a new post, adding a self tag', function () {
          expect(Posts.add).toHaveBeenCalledWith({ teacher_ids: [76] });
        });

        it('sets post to the new post', function () {
          expect(scope.post).toEqual('new post');
        });
      });

      describe('with a student logged in', function () {
        beforeEach(function () {
          User.type = 'Student';
          User.id = 3;

          controller('EditPostCtrl', { $scope: scope });
          scope.$apply();
        });

        it('adds a new post, adding a self tag', function () {
          expect(Posts.add).toHaveBeenCalledWith({ student_ids: [3] });
        });
      });

      describe('with a guardian logged in', function () {
        beforeEach(function () {
          User.type = 'Guardian';
          User.student_ids = [3, 4, 7];

          controller('EditPostCtrl', { $scope: scope });
          scope.$apply();
        });

        it('adds a new post, adding student tags', function () {
          expect(Posts.add).toHaveBeenCalledWith({ student_ids: [3, 4, 7] });
        });
      });

      describe('with a User that is loaded late', function () {
        var deferred;

        beforeEach(inject(function ($q) {
          deferred = $q.defer();
          User.promise = deferred.promise;

          controller('EditPostCtrl', { $scope: scope });
          scope.$apply();
        }));

        it('does not immediately add a post', function () {
          expect(scope.post).toBeUndefined();
          expect(Posts.add).not.toHaveBeenCalled();
        });

        it('does not add a post if the promise is rejected', function () {
          deferred.reject();
          scope.$apply();
          expect(scope.post).toBeUndefined();
          expect(Posts.add).not.toHaveBeenCalled();
        });

        it('adds a new post, adding student tags, if the promise is resolved', function () {
          deferred.resolve();
          scope.$apply();
          expect(Posts.add).toHaveBeenCalledWith({ teacher_ids: [76] });
          expect(scope.post).toEqual('new post');
        });
      });
    });

    describe('with a route id', function () {
      describe('on success', function () {
        beforeEach(function () {
          spyOn(Posts, 'update').andCallFake(function(data) {
            return 'post instance ' + data.id;
          });
          httpBackend.expectGET('/posts/5.json').respond({ id: 1, title: 'Some post' });
          controller('EditPostCtrl', { $scope: scope, $routeParams: { id: 5 } });
        });

        it('sends a request', function () {
          httpBackend.verifyNoOutstandingExpectation();
        });

        it('initially has posts undefined', function () {
          expect(scope.posts).toBeUndefined();
        });

        it('has pageTitle set', function () {
          expect(scope.pageTitle).toEqual('Edit post')
        });

        describe('on response', function () {
          beforeEach(function () {
            httpBackend.flush();
          });

          it('updates the Posts collection with the recieved data', function() {
            expect(Posts.update).toHaveBeenCalledWith({ id: 1, title: 'Some post' })
          });

          it('sets post to the post instance', function () {
            expect(scope.post).toEqual('post instance 1');
          });

          it('leaves pageTitle unchanged', function () {
            expect(scope.pageTitle).toEqual('Edit post');
          });
        });
      });

      describe('on failure', function () {
        beforeEach(function () {
          httpBackend.expectGET('/posts/5.json').respond(404);
          controller('EditPostCtrl', { $scope: scope, $routeParams: { id: 5 } });
          httpBackend.flush();
        });

        it('sets posts to null', function () {
          expect(scope.post).toBeNull();
        });

        it('changes pageTitle', function () {
          expect(scope.pageTitle).toEqual('Post not found');
        });
      });
    });

    describe('save()', function () {
      var post, deferred, location, childScope, listener;

      beforeEach(inject(function ($q, $location) {
        post = { url: function () { return '/some/path'; } };
        deferred = $q.defer();
        post.save = jasmine.createSpy().andReturn(deferred.promise);

        location = $location;
        spyOn(location, 'url');

        childScope = scope.$new();
        listener = jasmine.createSpy();
        childScope.$on('saveText', listener);

        spyOn(Posts, 'add').andReturn(post);
        controller('EditPostCtrl', { $scope: scope });
        scope.$apply();
        scope.save();
      }));

      it('broadcasts a saveText event', function () {
        expect(listener).toHaveBeenCalled();
      });

      it('calls the post instance save function', function () {
        expect(post.save).toHaveBeenCalled();
      });

      describe('when the promise is resolved', function () {
        beforeEach(function () {
          deferred.resolve(post);
          scope.$apply();
        });

        it('changes the url to the posts url', function () {
          expect(location.url).toHaveBeenCalledWith('/some/path');
        });
      });

      describe('when the promise is rejected', function () {
        beforeEach(function () {
          deferred.reject();
          scope.$apply();
        });

        it('does not change the url', function () {
          expect(location.url).not.toHaveBeenCalled();
        });
      });
    });

    // Delete a post
    describe('delete()', function () {
      var post, deferred;

      beforeEach(inject(function ($q) {
        deferred = $q.defer();
        post = { delete: jasmine.createSpy().andReturn(deferred.promise) };
        spyOn(Posts, 'add').andReturn(post);
        controller('EditPostCtrl', { $scope: scope });
        scope.$apply();
      }));

      describe('on confirm', function () {
        beforeEach(function () {
          scope.delete();
        });

        it('sends a delete message to the post', function () {
          expect(post.delete).toHaveBeenCalled();
        });

        it('does nothing to the post if the promise is rejected', function () {
          deferred.reject();
          scope.$apply();
          expect(scope.post).toBe(post);
          expect(scope.pageTitle).toEqual('Create a post');
        });

        it('removes the post and changes the pageTitle if the promise is resolved', function () {
          deferred.resolve();
          scope.$apply();
          expect(scope.post).toBeNull();
          expect(scope.pageTitle).toEqual('Post deleted');
        });
      });

      describe('on cancel', function () {
        beforeEach(function () {
          confirm.set(false);
          scope.delete()
        });

        it('does not send a delete message to the post', function () {
          expect(post.delete).not.toHaveBeenCalled();
        });
      });
    });

    describe('hideMenus()', function () {
      var childScope, listener;

      beforeEach(function () {
        childScope = scope.$new();
        listener = jasmine.createSpy();
        childScope.$on('hideMenus', listener);
        spyOn(Posts, 'add').andReturn('post');
        controller('EditPostCtrl', { $scope: scope });
        scope.hideMenus();
      });

      it('broadcasts a hideMenus event', function () {
        expect(listener).toHaveBeenCalled();
      });

      it('passes an empty array with the event', function () {
        expect(listener.mostRecentCall.args[1]).toEqual([]);
      });
    });

    describe('on image upload', function () {
      var post;

      beforeEach(function () {
        post = { };

        spyOn(Posts, 'add').andReturn(post);
        controller('EditPostCtrl', { $scope: scope });
        scope.$apply();
      });

      it('adds an image_id when no image_ids are set', function () {
        scope.$broadcast('imageUploaded', { id: 5 });
        expect(post.image_ids).toEqual([5]);
      });

      it('adds an image_id when image_ids are set', function () {
        post.image_ids = [1, 6];
        scope.$broadcast('imageUploaded', { id: 5 });
        expect(post.image_ids).toEqual([1, 6, 5]);
      });
    });
  });


  /*-------------------- Student observations controller ------------------*/

  describe('StudentObservationsCtrl', function () {
    var scope, childScope, listener, rootScope;

    beforeEach(inject(function ($rootScope, $controller) {
      rootScope = $rootScope;
      scope = $rootScope.$new();
      $controller('StudentObservationsCtrl', { $scope: scope });

      childScope = scope.$new();
      listener = jasmine.createSpy();
      childScope.$on('saveText', listener);
    }));

    describe('selectStudent', function () {
      beforeEach(function () {
        scope.selectStudent('some_student');
      });

      it('broadcasts a saveText event', function () {
        expect(listener).toHaveBeenCalled();
      });

      it('sets selectedStudent', function () {
        expect(scope.selectedStudent).toEqual('some_student');
      });
    });

    describe('on changing the post students', function () {
      var post, students;

      beforeEach(function () {
        students = [{short_name: 'a'}, {short_name: 'b'}, {short_name: 'c'}]
        post = rootScope.post = {};
      });

      it ('sends a check height event after a timeout', inject(function ($timeout) {
        listener = jasmine.createSpy();
        childScope.$on('checkHeight', listener);

        post.students = [];
        rootScope.$apply();

        $timeout.flush();
        expect(listener).toHaveBeenCalled();
      }));

      describe('with selectedStudent not set', function () {
        it('sets selectedStudent if students are added', function () {
          post.students = [students[1], students[0]];
          rootScope.$apply();
          expect(scope.selectedStudent).toEqual(students[0]);
        });

        it('does nothing if to selectedStudent if no students are added', function () {
          post.students = [];
          rootScope.$apply();
          expect(scope.selectedStudent).toBeUndefined();
        });
      });

      describe('with selectedStudent set', function () {
        beforeEach(function () {
          scope.selectedStudent = students[1];
        });

        it('does not set selected student if the selected student is present in the list', function () {
          post.students = [students[1], students[0]];
          rootScope.$apply();
          expect(scope.selectedStudent).toEqual(students[1]);
        });

        it('removes selectedStudent if no students are added', function () {
          post.students = [];
          rootScope.$apply();
          expect(scope.selectedStudent).toBeUndefined();
        });

        it('changes selectedStudent if the student is not present', function () {
          post.students = [students[2]];
          rootScope.$apply();
          expect(scope.selectedStudent).toEqual(students[2]);
        });
      });
    });
  });
});