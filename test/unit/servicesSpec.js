'use strict';

describe('service', function() {
  beforeEach(module('journalsApp.services'));

  describe('Person', function() {
    var result, $httpBackend;

    beforeEach(inject(function(_$httpBackend_) {
      $httpBackend = _$httpBackend_;
    }));

    it('should query people', inject(function(Person) {
      $httpBackend.expectGET('/people').respond([{id: 12, name: 'Student 1'}]);
      result = Person.query();
      $httpBackend.flush();
      expect(result[0].name).toBe('Student 1');
    }));
  });
});
