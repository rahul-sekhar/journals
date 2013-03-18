'use strict';

angular.module('journals.posts', ['ngSanitize', 'journals.ajax', 'journals.posts.models']).

  controller('PostsCtrl', ['$scope', 'ajax', 'Posts', '$location',
    function ($scope, ajax, Posts, $location) {
      var loadFn;

      $scope.pageTitle = 'Viewing posts';

      loadFn = function () {
        ajax({ url: $location.url() }).
          then(function (response) {
            $scope.posts = response.data.items.map(Posts.update);
            $scope.currentPage = response.data.current_page;
            $scope.totalPages = response.data.total_pages;
          }, function () {
            $scope.posts = [];
            $scope.currentPage = null;
            $scope.totalPages = null;
          });
      };

      // Handle parameter changes
      $scope.$on("$routeUpdate", function () {
        loadFn();
      });

      // Initial load
      loadFn();

    }]).

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
    }]).

  controller('EditPostCtrl', ['$scope', '$routeParams', 'Posts', 'ajax', '$location',
    function ($scope, $routeParams, Posts, ajax, $location) {
      if ($routeParams.id) {
        $scope.pageTitle = 'Edit post';
        ajax({ url: '/posts/' + $routeParams.id }).
          then(function (response) {
            $scope.post = Posts.update(response.data);
          }, function () {
            $scope.pageTitle = 'Post not found';
          });
      }
      else {
        $scope.pageTitle = 'Create a post';
        $scope.post = Posts.add();
      }

      $scope.save = function () {
        $scope.post.save().then(function (instance) {
          $location.url(instance.url());
        });
      };

      $scope.hideMenus = function () {
        $scope.$broadcast('hideMenus', []);
      };
    }]);
