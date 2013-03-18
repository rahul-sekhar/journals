'use strict';

describe('posts module', function () {
  beforeEach(module('journals.posts'));

  /*------------------- Posts controller ------------------*/

  describe('PostsCtrl', function () {
    var scope, httpBackend, controller, Posts, location;

    beforeEach(inject(function ($rootScope, $httpBackend, $controller, _Posts_, $location) {
      httpBackend = $httpBackend;
      scope = $rootScope.$new();
      controller = $controller;
      Posts = _Posts_;
      location = $location
      location.url('/path/to/posts')
      spyOn(Posts, 'update').andCallFake(function(data) {
        return 'post instance ' + data.id;
      });
    }));

    describe('on success', function () {
      beforeEach(function () {
        httpBackend.expectGET('/path/to/posts.json').respond({
          current_page: 2,
          total_pages: 4,
          items: [{ id: 1, title: 'Some post' }, {id: 2}, {id: 7}]
        });
        controller('PostsCtrl', { $scope: scope });
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
        controller('PostsCtrl', { $scope: scope });
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
        expect(scope.pageTitle).toEqual('Viewing a post')
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
      var post, deferred, location;

      beforeEach(inject(function ($q, $location) {
        post = { url: function () { return '/some/path'; } };
        deferred = $q.defer();
        post.save = jasmine.createSpy().andReturn(deferred.promise);

        location = $location;
        spyOn(location, 'url');

        spyOn(Posts, 'add').andReturn(post);
        controller('EditPostCtrl', { $scope: scope });
        scope.save();
      }));

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
        controller('EditPostCtrl', { $scope: scope });
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
  });
});