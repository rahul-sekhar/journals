'use strict';

angular.module('journals.posts', ['ngSanitize', 'journals.ajax', 'journals.posts.models', 'journals.confirm',
  'journals.help', 'journals.posts.directives']).

  controller('PostsCtrl', ['$scope', 'ajax', 'Posts', '$location', 'createHelpPost',
    function ($scope, ajax, Posts, $location, createHelpPost) {
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
    }]).

  controller('ViewPostCtrl', ['$scope', '$routeParams', 'ajax', 'Posts',
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
    }]).

  controller('EditPostCtrl', ['$scope', '$routeParams', 'Posts', 'ajax', '$location', 'confirm', 'User',
    function ($scope, $routeParams, Posts, ajax, $location, confirm, User) {
      if ($routeParams.id) {
        $scope.pageTitle = 'Edit post';
        ajax({ url: '/posts/' + $routeParams.id }).
          then(function (response) {
            $scope.post = Posts.update(response.data);
          }, function () {
            $scope.pageTitle = 'Post not found';
            $scope.post = null;
          });
      }
      else {
        $scope.pageTitle = 'Create a post';
        User.promise.
          then(function () {
            if (User.type === 'Teacher') {
              $scope.post = Posts.add({ teacher_ids: [User.id] });
            } else if (User.type === 'Student') {
              $scope.post = Posts.add({ student_ids: [User.id] });
            } else if (User.type === 'Guardian') {
              $scope.post = Posts.add({ student_ids: User.student_ids });
            }
          });
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

      $scope.delete = function () {
        var message = 'Are you sure you want to delete the post "' + $scope.post.title + '"?';

        if (confirm(message)) {
          $scope.post.delete().
            then(function () {
              $scope.pageTitle = 'Post deleted';
              $scope.post = null;
            });
        }
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
