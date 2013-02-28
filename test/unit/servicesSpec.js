'use strict';

describe('service', function() {

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
});