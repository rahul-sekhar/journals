'use strict';

describe('post directives module', function () {
  beforeEach(module('journals.posts.directives'));

  describe('PostCtrl', function () {
    var scope, confirm;

    beforeEach(inject(function ($rootScope, $controller, _confirm_) {
      confirm = _confirm_;
      scope = $rootScope.$new();
      $controller('PostCtrl', { $scope: scope });
    }));

    it('should set expanded to false', function () {
      expect(scope.expanded).toEqual(false);
    });

    describe('expand()', function () {
      beforeEach(function () {
        scope.expand();
      });

      it('sets expanded to true', function () {
        expect(scope.expanded).toEqual(true);
      });
    });

    describe('compact()', function () {
      beforeEach(function () {
        scope.expanded = true;
        scope.compact();
      });

      it('sets expanded to false', function () {
        expect(scope.expanded).toEqual(false);
      });
    });

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
});