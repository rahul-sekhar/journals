'use strict';

angular.module('journals.help', ['journals.posts', 'journals.user', 'journals.currentDate']).

  factory('helpSections', function () {
    return {
      viewPost: {
        path: '/posts',
        totalSteps: 3
      }
    }
  }).

  factory('help', ['helpSections', '$location', '$rootScope',
    function (helpSections, $location, $rootScope) {
      var deregistrationFn, help, showHelpOnRouteChange;

      help = {};

      // Hide help on route changes, except when 'showHelpOnRouteChange' is set
      $rootScope.$on('$routeChangeSuccess', function () {
        if (showHelpOnRouteChange) {
          help.shown = true;
          showHelpOnRouteChange = false;
        }
        else {
          help.shown = false;
        }
      });

      // Load a help section
      help.load = function (sectionName) {
        var section = helpSections[sectionName];

        if (!section) {
          throw new Error('Help section ' + sectionName + ' does not exist')
        }

        if ($location.path() !== section.path) {
          showHelpOnRouteChange = true;
          $location.url(section.path);
        }
        else {
          help.shown = true;
        }
      };

      // Hide the help
      help.close = function () {
        help.shown = false;
      };

      return help;
    }]).

  /*------------ Initialize ----------------*/

  run(['help', '$rootScope', function(help, $rootScope) {
    $rootScope.help = help;
  }]).


  /*--------------- Directive for a help step --------------*/
  directive('helpStep', [function () {
    return {
      restrict: 'E',
      scope: {
        step: '@',
        section: '@',
        object: '=',
        before: '&'
      },
      replace: true,
      template: '<div class="help-step" id="{{section}}-help-step-{{step}}" ng-class="{shown: (object.step == step)}">' +
          '<a href="" class="close" ng-click="close()"></a>' +
          '<p class="content" ng-transclude></p>' +
          '<p class="step">' +
            '<a href="" class="prev" ng-click="prev()"></a>' +
            '<span>{{step}} of {{totalSteps}}</span>' +
            '<a href="" class="next" ng-click="next()">Next</a>' +
          '</p>' +
        '</div>',
      transclude: true,
      controller: 'HelpStepCtrl'
    }
  }]).

  controller('HelpStepCtrl', ['$scope', 'helpSections', 'help', function ($scope, helpSections, help) {
    $scope.totalSteps = helpSections[$scope.section].totalSteps;

    $scope.$watch('object.step == step', function (value) {
      if (value && $scope.before) {
        $scope.before();
      }
    });

    $scope.close = function () {
      help.close();
    };

    $scope.prev = function () {
      var step = parseInt($scope.step, 10);
      if (step === 1) {
        // Back to the help menu
      }
      else {
        $scope.object.setStep(step - 1)
      }
    }

    $scope.next = function () {
      var step = parseInt($scope.step, 10);
      if (step === $scope.totalSteps) {
        help.close();
        // Back to the help menu or next in the tout
      }
      else {
        $scope.object.setStep(step + 1)
      }
    }
  }]).

  /*--------------- Help objects -------------*/

  factory('createHelpPost', ['User', 'currentDate', '$q', function (User, currentDate, $q) {
    return function () {
      var post = {
        step: 1,
        comments: [],
        editable: true,
        created_at: '25th March, 2013',
        title: 'Sample Post',
        content: '<p>Some explanation about this being a sample post. Lorem ipsum dolor sit amet, ne pri sint singulis, latine complectitur eam ne. Facilisis dissentiunt philosophia ne eam, id cum mucius possim, per ex mollis commodo insolens. Usu ad integre ceteros eligendi. Ea sed electram persecuti concludaturque, ad docendi accusamus usu.</p>' +
          '<p>Idque ponderum erroribus ius at, an omittam fastidii adolescens per. Mea an minim vivendo. Ad sed eros homero expetenda, quis graece noluisse mea id. Qui quod veritus appellantur te, quis modus torquatos per no, est ad prima essent. Eos eu diam zril indoctum.</p>'+
          '<p> In saperet inermis noluisse vix. Ea vim inani gubergren, ne his solum recusabo. Cu duo modo timeam, at usu putent facilisi gloriatur. Posse torquatos et mea, error atomorum ei eos. Wisi natum postulant usu id, suas cotidieque ex has. Ut omnes quaeque consulatu nec.</p>'+
          '<p>Eum brute sadipscing id. Usu ei case moderatius, no eam inani aliquid insolens. Ne ius eius disputando. Et assum quaestio neglegentur sea.</p>',
          student_observations: [],
          visible_to_guardians: true,
          visible_to_students: true
      };

      post.setStep = function (step) {
        post.step = step;
      };

      post.students = [
        { name: 'Mike Pontius', short_name: 'Mike', name_with_info: 'Mike Pontius (student)', url: function () { return ''; } }
      ];

      post.teachers = [
        { name: 'Dora Elmer', short_name: 'Dora', name_with_info: 'Dora Elmer (teacher)', url: function () { return ''; } }
      ]

      post.newComment = function (data) {
        var comment = {};
        comment.content = data.content;
        comment.author = User;
        comment.delete = function () {
          comment.deleted = true;
        };
        comment.updateField = function (field, value) {
          if (!value) {
            return;
          }
          comment[field] = value;
        };
        // Use current date here:
        comment.created_at = currentDate.getLong();
        comment.editable = true;

        post.comments.push(comment);

        comment.save = function () {
          return $q.when();
        };

        return comment;
      };

      post.author = post.teachers[0];

      return post;
    };
  }]);