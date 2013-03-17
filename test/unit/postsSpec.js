'use strict';

describe('posts module', function () {
  beforeEach(module('journals.posts'));

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
})