'use strict';

angular.module('journals.posts', ['ngSanitize', 'journals.ajax', 'journals.posts.models']).

  controller('ViewPostCtrl', ['$scope', '$routeParams', 'ajax', 'Posts',
    function ($scope, $routeParams, ajax, Posts) {

      $scope.pageTitle = 'Viewing a post';

      ajax({ url: '/posts/' + $routeParams.id }).
        then(function (response) {
          $scope.posts = [Posts.update(response.data)];
        }, function () {
          $scope.posts = [];
          $scope.pageTitle = 'Post not found';
        });
    }]);
