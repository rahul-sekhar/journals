'use strict';

describe('Tags module', function() {
  beforeEach(module('journals.tags'));

  /*---------- Tags service -----------------*/

  describe('Tags', function() {
    var collection, model, Tags;

    beforeEach(module(function($provide) {
      model = jasmine.createSpy().andReturn('model');
      collection = jasmine.createSpy().andReturn('collection');
      $provide.value('model', model);
      $provide.value('collection', collection);
    }));

    beforeEach(inject(function(_Tags_) {
      Tags = _Tags_;
    }));

    it('sets the model name to "tag"', function() {
      expect(model.mostRecentCall.args[0]).toEqual('tag');
    });

    it('sets the model url to "/tags"', function() {
      expect(model.mostRecentCall.args[1]).toEqual('/tags');
    });

    it('calls the collection with the model object', function() {
      expect(collection).toHaveBeenCalledWith('model', { reload: true });
    });

    it('returns the collection object', function() {
      expect(Tags).toEqual('collection');
    });
  });
});

