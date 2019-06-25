module Concerns
  module Underscore
    def underscore(camel_cased_word)
      Dry::Inflector.new.underscore(camel_cased_word)
    end
  end
end
