module ApiStruct
  module Extensions
    module ApiClient
      attr_reader :client

      def client_service(service)
        @client = service.new
        service.instance_methods(false).each do |method|
          define_client_method(method)
        end
      end

      private

      def define_client_method(method)
        define_singleton_method method do |*args|
          from_monad(client.send(method, *args))
        end
      end
    end
  end
end
