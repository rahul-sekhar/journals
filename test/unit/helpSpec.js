'use strict';

describe('Help module', function () {
  beforeEach(module('journals.help'));


  /*------------ Help service ---------------*/

  describe('help', function () {
    var help, location, sections = {}, scope, rootScope;

    beforeEach(module(function ($provide) {
      $provide.value('helpSections', sections);
    }));

    beforeEach(inject(function (_help_, $location, $rootScope) {
      help = _help_;
      location = $location;
      location.url;
      rootScope = $rootScope;
      scope = $rootScope.$new();
    }));

    it('has an undefined shown attribute', function () {
      expect(help.shown).toBeUndefined();
    });

    it('sets shown to false on a route change', function () {
      rootScope.$broadcast('$routeChangeSuccess');
      expect(help.shown).toEqual(false);
    });

    describe('load(section)', function () {
      beforeEach(function () {
        sections.testSection = {
          path: '/section/path'
        };
      });

      it('throws an error for an unknown section', function () {
        expect(function () { help.load('someSection', 1); }).toThrow('Help section someSection does not exist');
      });

      describe('when not on the section path', function () {
        beforeEach(function () {
          location.url('/some/path');
          spyOn(location, 'url');
          help.load('testSection', 1);
        });

        it('changes the location to the section path', function () {
          expect(location.url).toHaveBeenCalledWith('/section/path');
        });

        it('does not immediately change the shown attribute', function () {
          expect(help.shown).toBeUndefined();
        });

        describe('on a route change', function () {
          it('sets the shown attribute after the route is changed', function () {
            rootScope.$broadcast('$routeChangeSuccess');
            expect(help.shown).toEqual(true);
          });

          it('sets the shown attribute to false on a successive route change', function () {
            rootScope.$broadcast('$routeChangeSuccess');
            rootScope.$broadcast('$routeChangeSuccess');
            expect(help.shown).toEqual(false);
          });
        });
      });

      describe('when on the section path', function () {
        beforeEach(function () {
          location.url('/section/path?some_data=value');
          spyOn(location, 'url');
          help.load('testSection', 1);
        });

        it('does not change the location', function () {
          expect(location.url).not.toHaveBeenCalled();
        });

        it('sets the shown attribute', function () {
          expect(help.shown).toEqual(true);
        });
      });
    });

    describe('close()', function () {
      beforeEach(function () {
        help.shown = true;
        help.close();
      });

      it('sets shown to false', function () {
        expect(help.shown).toEqual(false);
      })
    });
  });

  describe('$rootScope functions', function () {
    var help, rootScope;

    beforeEach(inject(function ($rootScope, _help_) {
      help = _help_;
      rootScope = $rootScope;
    }));

    it('sets up a rootScope help object', function () {
      expect(rootScope.help).toBe(help);
    });
  });
})