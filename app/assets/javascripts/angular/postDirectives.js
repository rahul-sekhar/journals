'use strict';

angular.module('journals.posts.directives', ['journals.posts', 'journals.assets']).

  factory('postLinkFn', ['$timeout', function ($timeout) {
    return function () {
      return function (scope, elem, attrs) {
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

  controller('PostCtrl', ['$scope', function ($scope) {
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