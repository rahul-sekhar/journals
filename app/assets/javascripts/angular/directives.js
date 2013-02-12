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
          '<input ng-show="editMode" focus-on="editMode" ng-model="editorValue" finish-edit="finishEdit()" cancel-edit="cancelEdit()" ng-trim="false" />' +
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
          '<input ng-show="editMode" focus-on="editMode" ng-model="editorValue" finish-edit="finishEdit()" cancel-edit="cancelEdit()" ng-trim="false" />' +
        '</div>',
      replace: true,
      controller: 'InPlaceEditCtrl'
    }
  }).
  
  directive('smallHeadingField', function() {
    return {
      restrict: 'E',
      transclude: true,
      scope: { 
        parent: '=',
        fieldName: '@'
      },
      template:
        '<div class="heading-field">' +
          '<h4 ng-hide="editMode" ng-click="startEdit()">{{parent[fieldName]}}</h4>' +
          '<input ng-show="editMode" focus-on="editMode" ng-model="editorValue" finish-edit="finishEdit()" cancel-edit="cancelEdit()" ng-trim="false" />' +
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
          '<textarea ng-show="editMode" focus-on="editMode" ng-model="editorValue" finish-edit="finishEdit()" cancel-edit="cancelEdit()" ng-trim="false"></textarea>' +
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
        displayName: '@',
        fieldName: '@'
      },
      template:
        '<div class="field" ng-show="parent[fieldName]">' +
          '<p class="field-name">{{displayName | capitalize}}</p>' +
          '<p ng-hide="editMode" ng-click="startEdit()">{{parent[fieldName]}} ({{parent[fieldName] | dateToAge}} yrs)</p>' +
          '<input ng-show="editMode" focus-on="editMode" ng-model="editorValue" readonly="true" />' +
          '<a href="" class="clear-date" ng-click="clearEdit()" ng-show="editMode">clear</a>' +
        '</div>',
      replace: true,
      link: function( scope, elem, attrs ) {
        elem.find('input').datepicker({
          dateFormat: 'dd-mm-yy',
          changeMonth: true,
          changeYear: true,
          onClose: function(date) {
            scope.$apply(function() {
              scope.editorValue = date;
            });
            setTimeout(function() {
              scope.$apply("finishEdit()");
            }, 10);
          }
        });
      },
      controller: 'InPlaceEditCtrl'
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

  directive('cancelEdit', function() {
    return function( scope, elem, attrs ) {
      elem.
        on('keydown', function(e) {
          if (e.keyCode == 27) {
            scope.$apply(attrs.cancelEdit);
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