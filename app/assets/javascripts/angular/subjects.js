'use strict';

angular.module('journals.subjects', ['journals.ajax', 'journals.collection', 'journals.model', 'journals.confirm']).

  factory('Subjects', ['collection', 'model',
    function (collection, model) {
      var subjectModel = model('subject', '/academics/subjects');

      return collection(subjectModel);
    }]).

  controller('SubjectsCtrl', ['$scope', 'Subjects', 'confirm',
    function ($scope, Subjects, confirm) {

    $scope.pageTitle = 'Academic records';

    $scope.subjects = Subjects.all();

    $scope.add = function () {
      Subjects.add({_edit: 'name'});
    };

    $scope.delete = function (subject) {
      if (confirm('Are you sure you want to delete the subject "' + subject.name + '"?')) {
        subject.delete();
      }
    };
  }]);