'use strict';

describe('service', function() {
  
  beforeEach(function() {
    this.addMatchers({
      toEqualData: function(expected) {
        return angular.equals(this.actual, expected);
      },
      toEqualArrayData: function(expected) {
        return $(this.actual).not(expected).length == 0 && $(expected).not(this.actual).length == 0
      }
    });
  });

  beforeEach(module('journalsApp.services'));

  describe('profileFields', function() {
    describe("standard", function() {
      it("for students", inject(function(profileFields) {
        expect(profileFields.standard['students']).toEqual([
          "blood_group",
          "mobile",
          "home_phone",
          "office_phone",
          "email",
          "additional_emails",
        ]);
      }));

      it("for teachers", inject(function(profileFields) {
        expect(profileFields.standard['teachers']).toEqual([
          "mobile",
          "home_phone",
          "office_phone",
          "email",
          "additional_emails",
        ]);
      }));

      it("for guardians", inject(function(profileFields) {
        expect(profileFields.standard['guardians']).toEqual([
          "mobile",
          "home_phone",
          "office_phone",
          "email",
          "additional_emails",
        ]);
      }));
    });

    describe("date", function() {
      it("for students", inject(function(profileFields) {
        expect(profileFields.date['students']).toEqual(["birthday"]);
      }));

      it("for teachers", inject(function(profileFields) {
        expect(profileFields.date['teachers']).toEqual([]);
      }));

      it("for guardians", inject(function(profileFields) {
        expect(profileFields.date['guardians']).toEqual([]);
      }));
    });

    describe("multiLine", function() {
      it("for students", inject(function(profileFields) {
        expect(profileFields.multiLine['students']).toEqual(["address", "notes"]);
      }));

      it("for teachers", inject(function(profileFields) {
        expect(profileFields.multiLine['teachers']).toEqual(["address", "notes"]);
      }));

      it("for guardians", inject(function(profileFields) {
        expect(profileFields.multiLine['guardians']).toEqual(["address", "notes"]);
      }));
    });
  });

  describe('PeopleCtrlBase', function() {
    var PeopleCtrlBase, scope, $location, params, success_function;
    
    beforeEach(inject(function(_PeopleCtrlBase_, $rootScope, _$location_) {
      PeopleCtrlBase = _PeopleCtrlBase_;
      scope = $rootScope.$new();
      $location = _$location_;
      var query_function = function(arg1, arg2) {
        params = arg1;
        success_function = arg2;
      };

      PeopleCtrlBase.include(scope, query_function);
    }));

    it('calls the query function with no params', function() {
      expect(params).toEqual({});
    });

    describe('the success function', function() {
      it('is a function', function() {
        expect(typeof(success_function)).toEqual('function');
      });

      it('sets the scope people depending on the result', function() {
        var result = { items: [1,2,3] };
        expect(scope.people).toBeUndefined();
        success_function(result);
        expect(scope.people).toEqual([1,2,3]);
      });

      it('sets the current page', function() {
        var result = { current_page: 3 }
        expect(scope.currentPage).toBeUndefined();
        success_function(result);
        expect(scope.currentPage).toEqual(3);
      });

      it('sets the total pages', function() {
        var result = { total_pages: 8 }
        expect(scope.currentPage).toBeUndefined();
        success_function(result);
        expect(scope.totalPages).toEqual(8);
      });
    });

    describe('doSearch()', function() {
      it('changes the location search param depending on the scope search param', function() {
        scope.search = 'blah';
        expect($location.search().search).toBeUndefined();
        scope.doSearch();
        expect($location.search().search).toEqual('blah');
      });
    });

    it('calls the query function with updated parameters when the search param is changed', function() {
      $location.search('search', 'something');
      scope.$emit('$routeUpdate');
      expect(params).toEqual({search: 'something'});
    });

    it('calls the query function with updated parameters when the page param is changed', function() {
      $location.search('page', 4);
      scope.$emit('$routeUpdate');
      expect(params).toEqual({page: 4});
    });
    
    it('calls the query function with updated parameters when the page and search params are changed', function() {
      $location.search('page', 4).search('search', 'asdf');
      scope.$emit('$routeUpdate');
      expect(params).toEqual({page: 4, search: 'asdf'});
    });
  });
});