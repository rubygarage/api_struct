module ApiStruct
  class Entity < SimpleDelegator
    extend Extensions::DryMonads
    extend Extensions::ApiClient

    class << self
      attr_accessor :entity_attributes

      def attr_entity(*attrs)
        @entity_attributes = attrs

        entity_attributes.each do |attr|
          define_entity_attribute_getter(attr)
          define_entity_attribute_setter(attr)
        end
      end

      def has_entities(attr, options)
        entity_attributes << attr.to_sym
        define_method attr.to_s do
          self.class.collection(entity[attr], options[:as])
        end
      end

      def has_entity(attr, options)
        entity_attributes << attr.to_sym
        define_method attr.to_s do
          self.class.convert_to_entity(entity[attr], options[:as])
        end
      end

      def collection(entities, entity_type = self)
        raise EntityError, 'Collection must be a Array' unless entities.is_a? Array
        entities.map { |item| convert_to_entity(item, entity_type) }
      end

      def convert_to_entity(item, entity_type = self)
        raise EntityError, "#{entity_type} must be inherited from base_entity" unless entity_type < ApiStruct::Entity
        entity_type.new(item)
      end

      private

      def define_entity_attribute_getter(attr)
        define_method attr.to_s do
          entity[attr]
        end
      end

      def define_entity_attribute_setter(attr)
        define_method "#{attr}=" do |value|
          entity[attr] = value
        end
      end
    end

    attr_reader :entity, :entity_status

    def initialize(entity, status = true)
      raise EntityError, "#{entity} must be Hash" unless entity.is_a?(Hash)
      @entity = Hashie::Mash.new(extract_attributes(entity))
      @entity_status = entity_status
      __setobj__(@entity)
    end

    def success?
      entity_status == true
    end

    def failure?
      entity_status == false
    end

    private

    def extract_attributes(entity_attributes)
      entity_attributes.select { |key, value| self.class.entity_attributes.include?(key.to_sym) }
    end
  end

  class EntityError < StandardError; end
end
