module ApiStruct
  module Errors
    class Client
      attr_reader :status, :body, :error

      def initialize(response)
        if response.is_a?(Hash)
          @status = response[:status]
          @body = response[:body]
        else
          @status = response.status
          @body = parse_body(response.body.to_s)
        end
      end

      def to_s
        error
      end

      private

      def error
        return @status unless @body

        if @body['errors']
          @body['errors'].map do |k, v|
            v.map { |e| "#{k} #{e}".strip }.join("\n")
          end.join("\n")
        elsif @body['error']
          @body['error']
        else
          @status
        end
      end

      def parse_body(b)
        !b.empty? ? JSON.parse(b, symbolize_names: true) : nil
      rescue JSON::ParserError
        b
      end
    end
  end
end
