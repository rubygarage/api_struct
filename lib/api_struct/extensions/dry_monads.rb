module ApiStruct
  module Extensions
    module DryMonads
      def from_monad(monad)
        monad
          .fmap { |v| from_success(v) }.or_fmap { |e| from_failure(e) }.value!
      end

      def from_success(value)
        return Dry::Monads::Success(nil) if value.nil?

        value.is_a?(Array) ? collection(value) : new(value)
      end

      def from_failure(error)
        ApiStruct::Errors::Entity.new(
          { status: error.status, body: error.body, error: true }, false
        )
      end
    end
  end
end
