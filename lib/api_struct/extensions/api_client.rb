module ApiStruct
  module Extensions
    module ApiClient
      include Concerns::Underscore

      REJECTED_METHODS = %i[api_root default_path headers]

      attr_reader :clients

      def client_service(*services, **options)
        @clients ||= {}
        services.each { |service| register_service(service, options) }
      end

      private

      def register_service(service, options)
        options[:prefix] = prefix_from_class(service) if options[:prefix] == true
        options[:client_key] = options[:prefix] || :base

        @clients[options[:client_key]] = service
        allowed_methods(service, options).each { |method| define_client_method(method, options) }
      end

      def define_client_method(method, options)
        method_name = options[:prefix] ? [options[:prefix], method].join('_') : method
        define_singleton_method method_name do |*args|
          from_monad(clients[options[:client_key]].new.send(method, *args))
        end
      end

      def prefix_from_class(klass)
        underscore(klass.name.split('::').last).to_sym
      end

      def allowed_methods(service, options)
        return Array(options[:only]) if options[:only]
        rejected = REJECTED_METHODS.concat(Array(options[:except]))
        service.instance_methods(false).reject { |method| rejected.include?(method) }
      end
    end
  end
end
