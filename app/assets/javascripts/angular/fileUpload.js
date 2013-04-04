'use strict';

angular.module('journals.fileUpload', []).

  directive('fileUpload', [function () {
    return {
      restrict: 'E',
      scope: {
        url: '@',
        onUpload: '&'
      },
      replace: true,
      template:
        '<div class="file-upload">' +
          '<p class="notification">{{message}}</p>' +
          '<input type="file" ng-hide="uploading" />' +
          '<div class="progress" ng-show="uploading">' +
            '<span class="bar" ng-style="{width: progress + \'%\'}"></span>' +
            '<span class="text">{{progress + \'%\'}}</span>' +
          '</div>' +
        '</div>',
      controller: ['$scope', function ($scope) {
        var jqXHR;

        $scope.$on('resetUpload', function () {
          $scope.progress = 0;
          $scope.uploading = false;
          $scope.message = null;
        });

        $scope.$on('cancelUpload', function () {
          if (jqXHR) {
            jqXHR.abort();
          }
        });

        function validFormat (filename) {
          if (filename.slice(-4).toLowerCase() === 'jpeg') {
            return false;
          } else if (["jpg","png","gif"].indexOf(filename.slice(-3).toLowerCase()) === -1) {
            return false;
          }
          return true;
        }

        $scope.checkFile = function (file) {
          if (file.size > (2 * 1024 * 1024)) {
            $scope.message = 'The file cannot be more than 2 MB';
            return false;
          }
          else if(!validFormat(file.name)) {
            $scope.message = 'The file is not a valid format';
            return false;
          }

          return true;
        };

        $scope.startUpload = function (XHR) {
          jqXHR = XHR;
          $scope.progress = 0;
          $scope.uploading = true;
        };

        $scope.setProgress = function (data) {
          $scope.progress = parseInt(data.loaded / data.total * 100, 10);
        };

        $scope.success = function (data) {
          $scope.progress = 100;
          $scope.onUpload({imageData: data});
        };

        $scope.error = function (message) {
          $scope.uploading = false;
          $scope.message = message;
        }
      }],
      link: function (scope, elem, attrs) {
        elem.find('input[type="file"]').fileupload({
          url: scope.url,
          dataType: 'json',
          headers: {
            'X-CSRF-Token': $('meta[name=csrf-token]').attr('content')
          },
          add: function(e, data) {
            scope.$apply(function () {
              if (scope.checkFile(data.files[0])) {
                scope.startUpload(data.submit());
              }
            });
          },
          progress: function (e, data) {
            scope.$apply(function () {
              scope.setProgress(data);
            });
          },
          done: function (e, data) {
            scope.$apply(function () {
              scope.success(angular.fromJson(data.jqXHR.responseText))
            });
          },
          fail: function (e, data) {
            scope.$apply(function () {
              if (data.errorThrown !== "abort") {
                scope.error(data.jqXHR.responseText);
              }
            });
          }
        });
      }
    };
  }]);