'use strict';

angular.module('journals.posts.directives', ['journals.posts', 'journals.assets', 'journals.confirm']).

  factory('postLinkFn', ['$timeout', function ($timeout) {
    return function () {
      return function (scope, elem, attrs) {
        scope.scrollToComments = function () {
          var postContent, commentPos;

          postContent = elem.find('.post-content');
          commentPos = postContent.offset().top + postContent.prop('scrollHeight');

          scope.expanded = true;
          $('html, body').animate({
             scrollTop: commentPos
         }, 1000);
        };

        // Expand on clicking a post
        elem.on('click', function (e) {
          if (!$(e.target).is('a, textarea')) {
            scope.expand();
          }
        });
      };
    }
  }]).

  directive('post', ['assets', 'postLinkFn', function (assets, postLinkFn) {
    return {
      restrict: 'E',
      templateUrl: assets.url('post.html'),
      scope: {
        post: '='
      },
      controller: 'PostCtrl',
      link: postLinkFn()
    };
  }]).

  directive('helpPost', ['assets', 'postLinkFn', function (assets, postLinkFn) {
    return {
      restrict: 'E',
      templateUrl: assets.url('help_post.html'),
      scope: {
        post: '='
      },
      controller: 'PostCtrl',
      link: postLinkFn()
    };
  }]).

  controller('PostCtrl', ['$scope', 'confirm', '$location', '$anchorScroll',
    function ($scope, confirm, $location, $anchorScroll) {
      $scope.expanded = false;

      $scope.compact = function () {
        $scope.expanded = false;
      };

      $scope.expand = function () {
        $scope.expanded = true;
      };

      $scope.newCommentContent = null;

      $scope.addComment = function (content) {
        var comment;

        if (!content) {
          return;
        }
        comment = $scope.post.newComment({content: content});
        comment.save().
          then(function () {
            $scope.newComment = null;
          });
      };

      $scope.deleteComment = function (comment) {
        var message = 'Are you sure you want to delete this comment?'

        if (confirm(message)) {
          comment.delete();
        }
      };
    }]);