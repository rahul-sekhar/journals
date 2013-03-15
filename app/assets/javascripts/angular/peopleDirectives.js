'use strict';

angular.module('journals.people.directives', ['journals.assets', 'journals.currentDate']).

    /* -------------------- Profile fields directive ----------------------- */

  directive('profileFields', ['assets', function (assets) {
    return {
      restrict: 'E',
      transclude: true,
      scope: {
        person: '=parent'
      },
      templateUrl: assets.url('profile_fields_template.html'),
      replace: true,
      controller: 'profileFieldsCtrl'
    };
  }]).

  controller('profileFieldsCtrl', ['$scope', function ($scope) {
    $scope.fields = [];

    $scope.$watch('person.type', function (type) {
      var fields = [
        {name: "Mobile", slug: "mobile"},
        {name: "Home Phone", slug: "home_phone"},
        {name: "Office Phone", slug: "office_phone"},
        {name: "Email", slug: "email"},
        {name: "Additional Emails", slug: "additional_emails"},
        {name: "Address", slug: "address", type: "textarea", filter: "multiline"},
        {name: "Notes", slug: "notes", type: "textarea", filter: "multiline"}
      ];
      if (type === 'Student') {
        fields.unshift(
          {name: "Birthday", slug: "formatted_birthday", type: "date", filter: "dateWithAge"},
          {name: "Blood Group", slug: "blood_group"}
        );
      }
      fields = fields.map(function (obj) {
        if (!obj.type) {
          obj.type = 'text';
        }
        return obj;
      });
      $scope.fields = fields;
    });

    $scope.hasRemainingFields = function () {
      var i;

      for (i = 0; i < $scope.fields.length; i += 1) {
        // Return true if any field is empty
        if (!$scope.person[$scope.fields[i].slug]) {
          return true;
        }
      }
      return false;
    };

    $scope.addField = function (field) {
      $scope.person.editing[field] = true;
    };
  }]).

  /* ---------------------- Date with age filter ---------------------*/

  filter('dateWithAge', ['currentDate', function (currentDate) {
    return function (date_text) {
      if (!date_text) {
        return null;
      }

      var birthDate, currDate, age, m;

      birthDate = $.datepicker.parseDate('dd-mm-yy', date_text);
      currDate = currentDate.get();

      age = currDate.getFullYear() - birthDate.getFullYear();
      m = currDate.getMonth() - birthDate.getMonth();
      if (m < 0 || (m === 0 && currDate.getDate() < birthDate.getDate())) {
        age -= 1;
      }
      return date_text + ' (' + age + ' yrs)';
    };
  }]);