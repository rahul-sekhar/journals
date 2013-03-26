'use strict';

angular.module('journals.posts', ['ngSanitize', 'journals.ajax', 'journals.posts.models', 'journals.confirm',
  'journals.help', 'journals.posts.directives']).

  factory('postsBaseCtrl', ['confirm', function (confirm) {
    return function($scope) {
      $scope.delete = function (post) {
        var message = 'Are you sure you want to delete the post "' + post.title + '"?'

        if (confirm(message)) {
          post.delete();
        }
      };
    };
  }]).

  controller('PostsCtrl', ['$scope', 'ajax', 'Posts', '$location', 'postsBaseCtrl', 'createHelpPost',
    function ($scope, ajax, Posts, $location, postsBaseCtrl, createHelpPost) {
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

      // Handle searching
      $scope.search = $location.search().search;
      $scope.doSearch = function (value) {
        $location.search('search', value).
          search('page', null).
          replace();
      };

      // Handle parameter changes
      $scope.$on("$routeUpdate", function () {
        loadFn();
      });

      // Initial load
      loadFn();

      // Load help post
      $scope.helpPost = createHelpPost();
      $scope.$watch('help.shown', function (value) {
        if (value) {
          $scope.helpPost.setStep(1);
        } else {
          $scope.helpPost.setStep(null);
        }
      });

      postsBaseCtrl($scope);
    }]).

  controller('ViewPostCtrl', ['$scope', '$routeParams', 'ajax', 'Posts', 'postsBaseCtrl',
    function ($scope, $routeParams, ajax, Posts, postsBaseCtrl) {

      $scope.pageTitle = 'Viewing a post';
      $scope.single_post = true;

      ajax({ url: '/posts/' + $routeParams.id }).
        then(function (response) {
          $scope.posts = [Posts.update(response.data)];
          console.log($scope.posts[0]);
        }, function () {
          $scope.posts = [];
          $scope.pageTitle = 'Post not found';
        });

      postsBaseCtrl($scope);
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
        $scope.$broadcast('saveText');
        $scope.post.save().then(function (instance) {
          $location.url(instance.url());
        });
      };

      $scope.hideMenus = function () {
        $scope.$broadcast('hideMenus', []);
      };
    }]).

  controller('StudentObservationsCtrl', ['$scope', 'orderByFilter', '$timeout',
    function ($scope, orderByFilter, $timeout) {
      $scope.$watch('post.students', function (value) {
        // Send a checkHeight event on the next digest cycle so that the button list HTML changes
        // before the editor height is checked
        $timeout(function () {
          $scope.$broadcast('checkHeight');
        }, 0);

        if (value && value.indexOf($scope.selectedStudent) === -1) {
          $scope.selectedStudent = orderByFilter(value, 'short_name')[0];
        }
      }, true);

      $scope.selectStudent = function (student) {
        $scope.$broadcast('saveText');
        $scope.selectedStudent = student;
      };
    }]);
