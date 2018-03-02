module ApiStruct
  class Collection < SimpleDelegator
    attr_reader :collection

    def initialize(collection, entity_klass)
      raise EntityError, 'Collection must be a Array' unless collection.is_a? Array
      @collection = collection.map { |item| entity_klass.convert_to_entity(item) }
      __setobj__(@collection)
    end

    def success?
      true
    end

    def failure?
      false
    end
  end
end
