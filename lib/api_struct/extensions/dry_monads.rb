module ApiStruct
  module Extensions
    module DryMonads
      def from_monad(monad)
        monad.fmap { |v| from_right(v) }.or_fmap { |e| from_left(e) }.value
      end

      def from_right(value)
        value.is_a?(Array) ? collection(value) : new(value)
      end

      def from_left(error)
        ApiStruct::Errors::Entity.new({ status: error.status, body: error.body }, false)
      end
    end
  end
end
