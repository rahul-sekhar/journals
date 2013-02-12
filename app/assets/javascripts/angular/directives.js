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

  directive('headingField', function() {
    return {
      restrict: 'E',
      transclude: true,
      scope: { 
        parent: '=',
        fieldName: '@'
      },
      template:
        '<div class="heading-field">' +
          '<h3 ng-hide="editMode" ng-click="startEdit()">{{parent[fieldName]}}</h3>' +
          '<input ng-show="editMode" focus-on="editMode" ng-model="editorValue" finish-edit="finishEdit()" />' +
        '</div>',
      replace: true,
      controller: 'InPlaceEditCtrl'
    }
  }).
  
    

  directive('multiLineField', function() {
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
          '<p ng-bind-html="parent[field_name] | simpleFormat"></p>' +
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
  }).
  
  directive('finishEdit', function() {
    return function( scope, elem, attrs ) {
      elem.
        on('blur', function() {
          scope.$apply(attrs.finishEdit);
        }).
        on('keydown', function(e) {
          if (e.keyCode == 13) scope.$apply(attrs.finishEdit);
        });
    };
  }).

  directive('focusOn', function() {
    return function( scope, elem, attrs ) {
      scope.$watch(attrs.focusOn, function(value) {
        if (value) {
          window.setTimeout(function(){
            elem.focus();
          }, 10);
        }
      }, true);
    };
  });