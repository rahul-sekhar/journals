'use strict';

angular.module('journals.tinymce', ['journals.fileUpload']).

  directive('tinymce', ['imageDialog', 'linkDialog', function (imageDialog, linkDialog) {
    tinyMCE.baseURL = '/tinymce/';

    return {
      require: 'ngModel',
      link: function(scope, elem, attrs, ngModel) {
        var saveFn;

        elem.tinymce({
          popup_css : "/tinymce/themes/advanced/skins/default/dialog.css",
          width: 474,
          theme : "advanced",
          plugins : "autolink,lists,inlinepopups,paste,-ngimage,-nglink",
          content_css: "/assets/tinymce/main.css",
          theme_advanced_buttons1 : "bold,italic,strikethrough,|,nglink,unlink,|,bullist,numlist,|,ngimage,|,code",
          theme_advanced_toolbar_location : "top",
          theme_advanced_toolbar_align : "center",
          theme_advanced_resizing : true,
          theme_advanced_resize_horizontal : false,
          theme_advanced_statusbar_location : "bottom",
          theme_advanced_path: false,
          relative_urls: false,
          formats: {
            strikethrough : { inline : 'span', 'classes' : 'strikethrough', exact : true }
          },
          onchange_callback: function(e) {
            if (this.isDirty()) {
              saveFn();
              return true;
            }
          },
          oninit: function() {
            elem.trigger('editorInit');
          }
        });

        saveFn = function() {
          elem.tinymce().save();
          ngModel.$setViewValue(elem.val());
        };

        scope.$on('saveText', function () {
          saveFn();
        });
      }
    };
  }]).

  factory('imageDialog', ['$compile', '$rootScope', function ($compile, $rootScope) {
    var modal, scope, currentEditor;

    // Set up dialog
    modal = angular.element('<modal id="image-upload-dialog" show-on="dialogShown">' +
      '<p>Upload an image</p>' +
      '<file-upload url="/images.json" on-upload="uploaded(imageData)"></file-upload>' +
      '<button ng-click="cancel()">Cancel</button>' +
    '</modal>');

    modal.appendTo('body')
    scope = $rootScope.$new();
    modal = $compile(modal)(scope);

    scope.cancel = function () {
      scope.dialogShown = false;
    };

    scope.$watch('dialogShown', function (value) {
      if (value === false) {
        scope.$broadcast('cancelUpload');
        currentEditor.focus();
      }
    });

    scope.uploaded = function (imageData) {
      scope.dialogShown = false;
      currentEditor.execCommand('mceInsertContent', false, '<img src="' + imageData.url + '" alt="" />');
      $rootScope.$broadcast('imageUploaded', imageData);
    };

    // Set up plugin
    tinymce.create('tinymce.plugins.ngImage', {
      init: function (editor, url) {
        editor.addCommand('ngImage', function() {
          scope.$broadcast('resetUpload');
          currentEditor = editor;
          scope.$apply(function () {
            scope.dialogShown = true;
          });
        });

        editor.addButton('ngimage', {
          title : 'Insert image',
          cmd : 'ngImage',
          class: 'mce_image'
        });
      }
    });

    tinymce.PluginManager.add('ngimage', tinymce.plugins.ngImage);
  }]).

  factory('linkDialog', ['$compile', '$rootScope', function ($compile, $rootScope) {
    var modal, scope, currentEditor;

    // Set up dialog
    modal = angular.element('<modal id="link-dialog" show-on="dialogShown">' +
      '<div class="inputs">' +
        '<label for="link-url">{{linkSelected && "Add a link with the URL:" || "Edit link URL:"}}</label>' +
        '<input ng-model="link.url" id="link-url" />' +
      '</div>' +
      '<button ng-click="submit(link.url)">Ok</button>' +
      '<button ng-click="cancel()">Cancel</button>' +
    '</modal>');

    modal.appendTo('body')
    scope = $rootScope.$new();
    modal = $compile(modal)(scope);

    scope.link = {};

    scope.cancel = function () {
      scope.dialogShown = false;
    };

    scope.submit = function (url) {
      scope.dialogShown = false;

      if (url) {
        if (url.search('http') === -1) {
          url = 'http://' + url;
        }

        if (currentEditor.selection.getContent() || currentEditor.selection.getNode().nodeName === 'A') {
          currentEditor.execCommand('mceInsertLink', false, url);
        } else {
          currentEditor.execCommand('mceInsertContent', false, '<a href="' + url + '">' + url + '</a>');
        }
      }
    };

    scope.$watch('dialogShown', function (value) {
      if (value === false) {
        currentEditor.focus();
      }
    });

    // Set up plugin
    tinymce.create('tinymce.plugins.ngLink', {
      init: function (editor, url) {
        editor.addCommand('ngLink', function() {
          var selectedNode;

          currentEditor = editor;

          selectedNode = currentEditor.selection.getNode();
          scope.$apply(function () {
            if (selectedNode.nodeName === 'A') {
              scope.linkSelected = true;
              scope.link.url = $(selectedNode).attr('href');
            } else {
              scope.linkSelected = false;
              scope.link.url = '';
            }

            scope.dialogShown = true;
          });
        });

        editor.addButton('nglink', {
          title : 'Insert/Edit link',
          cmd : 'ngLink',
          class: 'mce_link'
        });
      }
    });

    tinymce.PluginManager.add('nglink', tinymce.plugins.ngLink);
  }]);