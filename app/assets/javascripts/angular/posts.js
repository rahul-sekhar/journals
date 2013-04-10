'use strict';

angular.module('journals.posts', ['ngSanitize', 'journals.ajax', 'journals.posts.models', 'journals.confirm',
  'journals.posts.directives', 'journals.searchFilters', 'journals.people.models',
  'journals.groups', 'journals.tags']).

  controller('PostsCtrl', ['$scope', 'ajax', 'Posts', '$location', 'searchFilters',
    'Students', 'Groups', 'Tags',
    function ($scope, ajax, Posts, $location, searchFilters, Students, Groups, Tags) {
      var loadFn, searchFiltersObj;

      $scope.pageTitle = 'Viewing posts';
      $scope.filters = {};

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

        angular.extend($scope.filters, searchFiltersObj.getCurrentValues());
      };

      // Filter lists
      $scope.students = Students.all();
      $scope.groups = Groups.all();
      $scope.tags = Tags.all();
      $scope.editing = {};

      // $scope.$watch('editing', function (val) {
      //   console.log(val);
      // });
      // $scope.$watch('filters', function (val) {
      //   console.log(val);
      // });

      $scope.hideMenus = function () {
        $scope.$broadcast('hideMenus', []);
      };

      $scope.$watch('filters.student', function (id) {
        if (id) {
          if (angular.isString(id)) {
            id = parseInt(id, 10);
          }
          Students.get(id).then(function (student) {
              $scope.studentName = student.name;
            });
        } else {
          $scope.studentName = 'All students';
        }
      });

      $scope.$watch('filters.group', function (id) {
        if (id) {
          if (angular.isString(id)) {
            id = parseInt(id, 10);
          }
          Groups.get(id).then(function (group) {
              $scope.groupName = group.name;
            });
        } else {
          $scope.groupName = 'All groups';
        }
      });

      $scope.$watch('filters.tag', function (id) {
        if (id) {
          if (angular.isString(id)) {
            id = parseInt(id, 10);
          }
          Tags.get(id).then(function (tag) {
              $scope.tagName = tag.name;
            });
        } else {
          $scope.tagName = 'All tags';
        }
      });

      // Handle filters
      searchFiltersObj = searchFilters(['search', 'student', 'group', 'tag', 'dateFrom', 'dateTo']);

      $scope.filter = function (filter, value) {
        $scope.filters[filter] = value;
        searchFiltersObj.filter(filter, value);
      };
      $scope.filters.updateField = $scope.filter;

      $scope.filterStudent = function (student) {
        if ($location.search().group) {
          $location.search('group', null);
        }
        $scope.filter('student', (student ? student.id : null));
      };

      $scope.filterGroup = function (group) {
        if ($location.search().student) {
          $location.search('student', null);
        }
        $scope.filter('group', (group ? group.id : null));
      };

      // Handle parameter changes
      $scope.$on("$routeUpdate", function () {
        loadFn();
      });

      // Initial load
      loadFn();

      // Load help post
      // $scope.helpPost = createHelpPost();
      // $scope.$watch('help.shown', function (value) {
      //   if (value) {
      //     $scope.helpPost.setStep(1);
      //   } else {
      //     $scope.helpPost.setStep(null);
      //   }
      // });
    }]).

  controller('ViewPostCtrl', ['$scope', '$routeParams', 'ajax', 'Posts',
    function ($scope, $routeParams, ajax, Posts, postsBaseCtrl) {

      $scope.pageTitle = 'Viewing a post';
      $scope.single_post = true;

      ajax({ url: '/posts/' + $routeParams.id }).
        then(function (response) {
          $scope.posts = [Posts.update(response.data)];
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

      $scope.$on('imageUploaded', function (event, imageData) {
        if (!$scope.post.image_ids) {
          $scope.post.image_ids = [];
        }
        $scope.post.image_ids.push(imageData.id);
      });
    }]).

  controller('StudentObservationsCtrl', ['$scope', 'orderByFilter', '$timeout',
    function ($scope, orderByFilter, $timeout) {
      $scope.$watch('post.students.length', function () {
        // Send a checkHeight event on the next digest cycle so that the button list HTML changes
        // before the editor height is checked
        $timeout(function () {
          $scope.$broadcast('checkHeight');
        }, 0);

        var students = $scope.post && $scope.post.students;
        if (students && students.indexOf($scope.selectedStudent) === -1) {
          $scope.selectedStudent = orderByFilter(students, 'short_name')[0];
        }
      });

      $scope.selectStudent = function (student) {
        $scope.$broadcast('saveText');
        $scope.selectedStudent = student;
      };
    }]);
