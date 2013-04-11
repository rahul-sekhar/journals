'use strict';

describe('editInPlace module', function () {
  beforeEach(module('journals.editInPlace'));

  /* -------- editInPlace directive ---------- */
  describe('editInPlace', function () {
    describe('for a text field', function () {
      var elem, scope, rootScope, input, fieldSpan;

      beforeEach(inject(function ($rootScope, $compile) {
        elem = angular.element('<p edit-in-place instance="someInstance" edit-mode="editOn" type="text" field="someAttr"></p>').appendTo('body');
        scope = $rootScope;
        scope.someInstance = { someAttr: 'value' };
        $compile(elem)(scope);
        scope.$apply();
        input = elem.find('input');
        fieldSpan = elem.find('span.value');
      }));

      it('adds a .container span', function () {
        expect(elem.children().length).toEqual(1);
        expect(elem.children('span.container').length).toEqual(1);
      });

      it('adds a .value span with the value of the attribute', function () {
        expect(fieldSpan.length).toEqual(1);
        expect(fieldSpan.text()).toEqual('value');
        expect(fieldSpan.is(':visible')).toEqual(true);
      });

      it('adds an initially hidden input element', function () {
        expect(input.length).toEqual(1);
        expect(input.is(':visible')).toEqual(false);
      });

      describe('with editMode true', function () {
        beforeEach(function () {
          scope.editOn = true;
          scope.$apply();
        });

        it('hides the fieldSpan', function () {
          expect(fieldSpan.is(':visible')).toEqual(false);
        });

        it('shows the input', function () {
          expect(input.is(':visible')).toEqual(true);
        });
      });

      describe('when the field is clicked', function () {
        var timeout;

        beforeEach(inject(function ($timeout) {
          spyOn($.fn, 'focus');
          fieldSpan.click();
          scope.$apply();
          timeout = $timeout;
        }));

        it('sets the input value to the attribute value', function () {
          expect(input.val()).toEqual('value');
        });

        it('does not change the attribute when the input is changed', function () {
          input.val('some other val').trigger('input');
          scope.$apply();
          expect(scope.someInstance.someAttr).toEqual('value');
        });

        it('hides the fieldSpan', function () {
          expect(fieldSpan.is(':visible')).toEqual(false);
        });

        it('shows and focuses on the input', function () {
          expect(input.is(':visible')).toEqual(true);
          timeout.flush();
          expect($.fn.focus).toHaveBeenCalled();
          expect($.fn.focus.mostRecentCall.object[0]).toEqual(input[0]);
        });

        describe('when the input value is changed', function () {
          beforeEach(function () {
            scope.someInstance.updateField = jasmine.createSpy();
            input.val('changed value').trigger('input');
            scope.$apply();
          });

          var runFinishEditExamples = function () {
            it('calls the update function with the change value', function () {
              expect(scope.someInstance.updateField).toHaveBeenCalledWith('someAttr', 'changed value');
            });

            it('shows the fieldSpan', function () {
              expect(fieldSpan.is(':visible')).toEqual(true);
            });

            it('hides the input', function () {
              expect(input.is(':visible')).toEqual(false);
            });
          };

          describe('when enter is pressed', function () {
            beforeEach(function () {
              var press = $.Event("keydown");
              press.keyCode = 13;
              input.trigger(press);
            });

            runFinishEditExamples();
          });

          describe('when the input is blurred', function () {
            beforeEach(function () {
              input.blur();
            });

            runFinishEditExamples();
          });

          describe('when the escape key is pressed', function () {
            beforeEach(function () {
              var press = $.Event("keydown");
              press.keyCode = 27;
              input.trigger(press);
            });

            it('does not call the parent function', function () {
              expect(scope.someInstance.updateField).not.toHaveBeenCalled();
            });

            it('shows the fieldSpan', function () {
              expect(fieldSpan.is(':visible')).toEqual(true);
            });

            it('hides the input', function () {
              expect(input.is(':visible')).toEqual(false);
            });
          });
        });
      });
    });

    describe('for an invalid type', function () {
      var elem, scope;

      beforeEach(inject(function ($rootScope, $compile) {
        elem = angular.element('<p edit-in-place instance="someInstance" type="other" edit-mode="editOn" field="someAttr">Some text</p>').appendTo('body');
        scope = $rootScope.$new();
        scope.someInstance = {};
        $compile(elem)(scope);
      }));

      it('should throw an exception', function () {
        expect(scope.$apply).toThrow('editInPlace type not recognized - other');
      });
    });
  });

  /* -------- editInPlace controller ---------- */
  describe('editInPlaceCtrl', function () {
    var scope, ctrl, rootScope;

    beforeEach(inject(function ($rootScope, $controller) {
      rootScope = $rootScope;
      scope = $rootScope.$new();
      scope.field = 'attr';
      scope.instance = { attr: 'value', updateField: jasmine.createSpy() };
      ctrl = $controller('editInPlaceCtrl', { $scope: scope })
    }));

    it('does not set the editor value', function () {
      expect(scope.editorValue).toBeUndefined();
    });

    it('initially has editMode undefined', function () {
      expect(scope.editMode).toBeUndefined();
    });

    describe('when the instances _edit attribute is set', function () {
      describe('with a new instance', function () {
        beforeEach(function () {
          scope.instance.isNew = function () { return true; }
        });

        describe('with the correct field', function() {
          beforeEach(function () {
            scope.instance._edit = 'attr';
            scope.$apply();
          });

          it('sets editMode to true', function() {
            expect(scope.editMode).toEqual(true);
          });
        });

        describe('with a different field', function() {
          beforeEach(function () {
            scope.instance._edit = 'attr1';
            scope.$apply();
          });

          it('does not set editMode', function() {
            expect(scope.editMode).toBeUndefined();
          });
        });
      });

      describe('with an existing instance', function () {
        beforeEach(function () {
          scope.instance.isNew = function () { return false; }
        });

        describe('with the correct field', function() {
          beforeEach(function () {
            scope.instance._edit = 'attr';
            scope.$apply();
          });

          it('does not change editMode', function() {
            expect(scope.editMode).toBeUndefined();
          });
        });
      });
    });

    describe('startEdit()', function () {
      beforeEach(function () {
        scope.startEdit();
      });

      it('sets editMode to true', function () {
        expect(scope.editMode).toEqual(true);
      });
    });

    describe('when editMode is changed', function () {
      it('sets the editorValue to the parentValue if true', function () {
        scope.editMode = true;
        scope.$apply();
        expect(scope.editorValue).toEqual('value');
      });

      it('does nothing if false', function () {
        scope.editMode = false;
        scope.$apply();
        expect(scope.editorValue).toBeUndefined();
      });
    });

    describe('finishEdit()', function () {
      beforeEach(function () {
        scope.editorValue = 'someval';
        scope.editMode = true;
        scope.finishEdit();
      });

      it('calls the instance updateField function', function () {
        expect(scope.instance.updateField).toHaveBeenCalledWith('attr', 'someval');
      });

      it('sets editMode to false', function () {
        expect(scope.editMode).toEqual(false);
      });
    });

    describe('cancelEdit()', function () {
      beforeEach(function () {
        scope.editMode = true;
        scope.cancelEdit();
      });

      it('sets editMode to false', function () {
        expect(scope.editMode).toEqual(false);
      });
    });

    describe('clearEdit()', function () {
      beforeEach(function () {
        scope.editorValue = 'someval';
        scope.editMode = true;
        scope.clearEdit();
      });

      it('calls instance updateField function with a NULL value', function () {
        expect(scope.instance.updateField).toHaveBeenCalledWith('attr', null);
      });

      it('sets editMode to false', function () {
        expect(scope.editMode).toEqual(false);
      });
    });
  });

  /* -------- focusOn directive ---------- */
  describe('focusOn', function () {
    var elem, scope, timeout;

    beforeEach(inject(function ($rootScope, $compile, $timeout) {
      elem = angular.element('<input focus-on="someAttr" />');
      spyOn($.fn, 'focus');
      timeout = $timeout;
      scope = $rootScope;
      scope.someAttr = false;
      $compile(elem)(scope);
      scope.$apply();
    }));

    it('initially has no focus', function () {
      expect($.fn.focus).not.toHaveBeenCalled();
    });

    it('gains focus when someAttr is changed to true', function () {
      scope.someAttr = true;
      scope.$apply();
      timeout.flush();
      expect($.fn.focus).toHaveBeenCalled();
      expect($.fn.focus.mostRecentCall.object[0]).toEqual(elem[0]);
    });
  });

  /* -------- EditObject controller ---------- */
  describe('EditObjectCtrl', function () {
    var scope, ctrl;

    beforeEach(inject(function ($rootScope, $controller) {
      scope = $rootScope.$new();
      $controller('EditObjectCtrl', { $scope: scope });
    }));

    it('sets editing to an object', function () {
      expect(scope.editing).toEqual({});
    });
  });
});