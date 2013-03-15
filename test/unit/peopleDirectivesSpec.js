'use strict'

describe('people directives module', function() {
  beforeEach(module('journals.people.directives'));

  /*--------------- Profile fields controller --------------*/
  describe('profileFieldsCtrl', function() {
    var scope;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      $controller('profileFieldsCtrl', { $scope: scope });
    }));

    it('sets fields to blank initially', function() {
      expect(scope.fields).toEqual([]);
    });

    it('sets a students fields', function() {
      scope.person = { type: 'Student' };
      scope.$apply();
      var field_names = scope.fields.map(function(obj) {
        return obj.slug;
      });
      expect(field_names).toEqual([
        "formatted_birthday",
        "blood_group",
        "mobile",
        "home_phone",
        "office_phone",
        "email",
        "additional_emails",
        "address",
        "notes"
      ]);
    });

    it('sets a teachers fields', function() {
      scope.person = { type: 'Teacher' };
      scope.$apply();
      var field_names = scope.fields.map(function(obj) {
        return obj.slug;
      });
      expect(field_names).toEqual([
        "mobile",
        "home_phone",
        "office_phone",
        "email",
        "additional_emails",
        "address",
        "notes"
      ]);
    });

    it('sets a guardians fields', function() {
      scope.person = { type: 'Guardian' };
      scope.$apply();
      var field_names = scope.fields.map(function(obj) {
        return obj.slug;
      });
      expect(field_names).toEqual([
        "mobile",
        "home_phone",
        "office_phone",
        "email",
        "additional_emails",
        "address",
        "notes"
      ]);
    });

    describe('hasRemainingFields()', function() {
      var person;

      beforeEach(function() {
        person = scope.person = { type: 'Student' };
        scope.$apply();
      });

      it('returns true if some fields are not set', function() {
        person.home_phone = 'blah blah';
        person.address='something';
        person.blood_group = 'A+';

        scope.$apply();

        expect(scope.hasRemainingFields()).toEqual(true);
      });

      it('returns false if all fields are set', function() {
        person.type = 'Student'
        person.home_phone = 'blah blah';
        person.address='something';
        person.email = 'a@b.c';
        person.mobile = '1234';
        person.formatted_birthday = '11/12/1990';
        person.office_phone = '2345';
        person.blood_group = 'A+';
        person.additional_emails = 'asdf';
        person.notes = 'bcd';

        scope.$apply();

        expect(scope.hasRemainingFields()).toEqual(false);
      });
    });

    describe('addField(field_name)', function() {
      beforeEach(function() {
        scope.editing = {};
        scope.addField('some_field');
      });

      it('sets editing to true for that field', function() {
        expect(scope.editing['some_field']).toEqual(true);
      });
    });
  });


  /*---------------- Date with age filter ---------------*/

  describe('dateWithAge', function() {
    var currentDateMock

    beforeEach(function() {
      module(function($provide) {
        currentDateMock = {
          get: function() {
            return new Date('2013-01-01')
          }
        };
        $provide.value('currentDate', currentDateMock)
      });
    });

    it('converts a date to an age', inject(function(dateWithAgeFilter) {
      expect(dateWithAgeFilter('24-04-2007')).toEqual('24-04-2007 (5 yrs)');
    }));

    it('returns null for a null date', inject(function(dateWithAgeFilter) {
      expect(dateWithAgeFilter(null)).toEqual(null);
    }));

    it('returns null for a blank date', inject(function(dateWithAgeFilter) {
      expect(dateWithAgeFilter('')).toEqual(null);
    }));
  });
});