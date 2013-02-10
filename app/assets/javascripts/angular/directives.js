'use strict';

/* Directives */


angular.module('journalsApp.directives', []).
  
  directive('field', function() {
    return {
      restrict: 'E',
      transclude: true,
      scope: { 
        parent: '=',
        field_name: '@name'
      },
      template:
        '<div class="field" ng-show="parent[field_name]">' +
          '<p class="field-name">{{field_name | capitalize}}</p>' +
          '<p>{{parent[field_name]}}</p>' +
        '</div>',
      replace: true
    }
  }).

  directive('dateField', function() {
    return {
      restrict: 'E',
      transclude: true,
      scope: {
        parent: '=',
        fieldName: '@name',
        functionName: '@'
      },
      template:
        '<div class="field" ng-show="parent[functionName]">' +
          '<p class="field-name">{{fieldName | capitalize}}</p>' +
          '<p>{{parent[functionName]}} ({{parent[functionName] | dateToAge}} yrs)</p>' +
        '</div>',
      replace: true
    }
  });
  
//   directive('jnlBlur', function() {
//     return function( scope, elem, attrs ) {
//       elem.on('blur', function() {
//         scope.$apply(attrs.ngBlur);
//       });
//     };
//   }).

//   directive('jnlFocusOn', function() {
//     return function( scope, elem, attrs ) {
//       scope.$watch(attrs.ngFocusOn, function(value) {
//         if (value) {
//           window.setTimeout(function(){
//             elem.focus();
//           }, 10);
//         }
//       }, true);
//     };
//   });