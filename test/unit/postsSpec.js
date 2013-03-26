'use strict';

describe('posts module', function () {
  beforeEach(module('journals.posts'));

  /*------------------ Posts base controller ------------------*/
  describe('postsBaseCtrl', function () {
    var scope, confirm;

    beforeEach(inject(function ($rootScope, postsBaseCtrl, _confirm_) {
      confirm = _confirm_;

      scope = $rootScope.$new();
      scope.load = jasmine.createSpy();

      postsBaseCtrl(scope);
    }));

    // Delete a post
    describe('delete(post)', function () {
      var post;

      beforeEach(function () {
        post = { delete: jasmine.createSpy() };
      });

      describe('on confirm', function () {
        beforeEach(function () {
          scope.delete(post)
        });

        it('sends a delete message to the post', function () {
          expect(post.delete).toHaveBeenCalled();
        });
      });

      describe('on cancel', function () {
        beforeEach(function () {
          confirm.set(false);
          scope.delete(post)
        });

        it('does not send a delete message to the post', function () {
          expect(post.delete).not.toHaveBeenCalled();
        });
      });
    });

    // Delete a comment
    describe('deleteComment(comment)', function () {
      var comment;

      beforeEach(function () {
        comment = { delete: jasmine.createSpy() };
      });

      describe('on confirm', function () {
        beforeEach(function () {
          scope.deleteComment(comment)
        });

        it('sends a delete message to the comment', function () {
          expect(comment.delete).toHaveBeenCalled();
        });
      });

      describe('on cancel', function () {
        beforeEach(function () {
          confirm.set(false);
          scope.deleteComment(comment)
        });

        it('does not send a delete message to the comment', function () {
          expect(comment.delete).not.toHaveBeenCalled();
        });
      });
    });
  });

  /*------------------- Posts controller ------------------*/

  describe('PostsCtrl', function () {
    var scope, httpBackend, controller, Posts, location, postsBaseCtrl, createHelpPost, helpPost;

    beforeEach(inject(function ($rootScope, $httpBackend, $controller, _Posts_, $location) {
      httpBackend = $httpBackend;

      scope = $rootScope.$new();
      controller = $controller;

      postsBaseCtrl = jasmine.createSpy();
      Posts = _Posts_;
      location = $location;

      location.url('/path/to/posts')
      spyOn(Posts, 'update').andCallFake(function (data) {
        return 'post instance ' + data.id;
      });

      helpPost = { setStep: jasmine.createSpy() }
      createHelpPost = jasmine.createSpy().andReturn(helpPost);
    }));

    describe('when the search param is pre-set', function () {
      beforeEach(function () {
        location.url('/some/path?search=blahblah');
        httpBackend.expectGET('/some/path.json?search=blahblah').respond(200);
        controller('PostsCtrl', { $scope: scope, postsBaseCtrl: postsBaseCtrl, createHelpPost: createHelpPost });
      });

      it('sets the scope seach val', function () {
        expect(scope.search).toEqual('blahblah');
      })
    });

    describe('on success', function () {
      beforeEach(function () {
        httpBackend.expectGET('/path/to/posts.json').respond({
          current_page: 2,
          total_pages: 4,
          items: [{ id: 1, title: 'Some post' }, {id: 2}, {id: 7}]
        });
        controller('PostsCtrl', { $scope: scope, postsBaseCtrl: postsBaseCtrl, createHelpPost: createHelpPost });
      });

      it('includes the base controller', function () {
        expect(postsBaseCtrl).toHaveBeenCalledWith(scope);
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

      describe('helpPost', function () {
        it('creates a help post instance', function () {
          expect(createHelpPost).toHaveBeenCalled();
          expect(scope.helpPost).toBe(helpPost);
        });

        it('sets the helpPost step to 1 when help is shown', function () {
          expect(helpPost.setStep).not.toHaveBeenCalled();
          scope.help.shown = true;
          scope.$apply();
          expect(helpPost.setStep).toHaveBeenCalledWith(1);
        });
      });

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
      });
    });

    describe('on failure', function () {
      beforeEach(function () {
        httpBackend.expectGET('/path/to/posts.json').respond(400);
        controller('PostsCtrl', { $scope: scope, createHelpPost: createHelpPost });
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
    var scope, httpBackend, controller, Posts, postsBaseCtrl;

    beforeEach(inject(function ($rootScope, $httpBackend, $controller, _Posts_) {
      httpBackend = $httpBackend;

      scope = $rootScope.$new();
      controller = $controller;

      postsBaseCtrl = jasmine.createSpy();

      Posts = _Posts_;
      spyOn(Posts, 'update').andCallFake(function(data) {
        return 'post instance ' + data.id;
      });
    }));

    describe('on success', function () {
      beforeEach(function () {
        httpBackend.expectGET('/posts/5.json').respond({ id: 1, title: 'Some post' });
        controller('ViewPostCtrl', { $scope: scope, $routeParams: { id: 5 }, postsBaseCtrl: postsBaseCtrl });
      });

      it('includes the base controller', function () {
        expect(postsBaseCtrl).toHaveBeenCalledWith(scope);
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





  /*------------------------ Controller for each post ---------------------*/

  describe('PostCtrl', function () {
    var scope;

    beforeEach(inject(function ($rootScope, $controller) {
      scope = $rootScope.$new();
      $controller('PostCtrl', { $scope: scope });
    }));

    it('sets newComment to null', function () {
      expect(scope.newComment).toEqual(null);
    });

    describe('addComment(content)', function () {
      var newComment, deferred;

      beforeEach(inject(function ($rootScope, $controller, $q) {
        deferred = $q.defer();
        newComment = { save: jasmine.createSpy().andReturn(deferred.promise) };
        scope.post = { newComment: jasmine.createSpy().andReturn(newComment) };
        scope.newComment = 'Some val';
      }));

      describe('with no content', function () {
        beforeEach(function () {
          scope.addComment('');
        });

        it('does nothing', function () {
          expect(scope.post.newComment).not.toHaveBeenCalled();
          expect(scope.newComment).toEqual('Some val');
        });
      });

      describe('with content', function () {
        beforeEach(function () {
          scope.addComment('Some content');
        });

        it('calls post.newComment with passed content', function () {
          expect(scope.post.newComment).toHaveBeenCalledWith({content: 'Some content'});
        });

        it('saves the returned comment', function () {
          expect(newComment.save).toHaveBeenCalled();
        })

        it('sets the scope newComment content to null if the promise is resolved', function () {
          deferred.resolve();
          scope.$apply();
          expect(scope.newComment).toBeNull();
        });

        it('leaves the scope newComment content alone if the promise is rejected', function () {
          deferred.reject();
          scope.$apply();
          expect(scope.newComment).toEqual('Some val');
        });
      });
    });
  });

  /*------------------------ Edit post controller ------------------------*/


  describe('EditPostCtrl', function () {
    var scope, httpBackend, controller, Posts;

    beforeEach(inject(function ($rootScope, $httpBackend, $controller, _Posts_) {
      httpBackend = $httpBackend;
      scope = $rootScope.$new();
      controller = $controller;
      Posts = _Posts_;
    }));

    describe('with no route id', function () {
      beforeEach(function () {
        spyOn(Posts, 'add').andReturn('new post');
        controller('EditPostCtrl', { $scope: scope });
      });

      it('sets pageTitle', function () {
        expect(scope.pageTitle).toEqual('Create a post');
      })

      it('adds a new post', function () {
        expect(Posts.add).toHaveBeenCalled();
      });

      it('sets post to the new post', function () {
        expect(scope.post).toEqual('new post');
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
          controller('ViewPostCtrl', { $scope: scope, $routeParams: { id: 5 } });
          httpBackend.flush();
        });

        it('sets posts to an empty array', function () {
          expect(scope.post).toBeUndefined();
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

    describe('hideMenus()', function () {
      var childScope, listener;

      beforeEach(function () {
        childScope = scope.$new();
        listener = jasmine.createSpy();
        childScope.$on('hideMenus', listener);
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