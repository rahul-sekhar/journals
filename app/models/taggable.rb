module Taggable
  module ClassMethods
    
    def name_is(input_name)
      input_name = SqlHelper::escapeWildcards(input_name)
      self.where{ name.like input_name }.first
    end

    
    def find_or_build_list(names)
      names.split(',')
        .map{ |name| name.strip }
        .reject{ |name| name.blank? }
        .uniq{ |tag| tag.downcase }
        .map { |name| name_is(name) || new(name: name) }
    end

    def alphabetical
      order(:name)
    end
    
  end

  def self.included(base)
    base.extend ClassMethods
  end
end