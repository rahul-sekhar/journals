'use strict';

/* Directives */


angular.module('journalsApp.directives', []).
  
  directive('field', function() {
    return {
      restrict: 'E',
      transclude: true,
      scope: { 
        parent: '=',
        fieldName: '@'
      },
      template:
        '<div class="field" ng-show="parent[fieldName]">' +
          '<p class="field-name">{{fieldName | capitalize}}</p>' +
          '<p ng-hide="editMode" ng-click="startEdit()">{{parent[fieldName]}}</p>' +
          '<input ng-show="editMode" focus-on="editMode" ng-model="editorValue" finish-edit="finishEdit()" ng-trim="false" />' +
        '</div>',
      replace: true,
      controller: 'InPlaceEditCtrl'
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
          '<input ng-show="editMode" focus-on="editMode" ng-model="editorValue" finish-edit="finishEdit()" ng-trim="false" />' +
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
        fieldName: '@'
      },
      template:
        '<div class="field" ng-show="parent[fieldName]">' +
          '<p class="field-name">{{fieldName | capitalize}}</p>' +
          '<p ng-hide="editMode" ng-click="startEdit()" ng-bind-html="parent[fieldName] | simpleFormat"></p>' +
          '<textarea ng-show="editMode" focus-on="editMode" ng-model="editorValue" finish-edit="finishEdit()" ng-trim="false"></textarea>' +
        '</div>',
      replace: true,
      controller: 'InPlaceEditCtrl'
    }
  }).

  directive('dateField', function() {
    return {
      restrict: 'E',
      transclude: true,
      scope: {
        parent: '=',
        fieldName: '@',
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
          if (e.keyCode == 13 && elem.is("input")) {
            scope.$apply(attrs.finishEdit);
          }
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