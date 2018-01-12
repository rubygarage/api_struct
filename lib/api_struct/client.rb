module ApiStruct
  class Client
    attr_reader :client

    def self.method_missing(method_name, *args, &block)
      endpoints = Settings.config.endpoints
      return super unless endpoints.keys.include?(method_name)

      define_method(:root) do
        endpoints[method_name][:root] + first_arg(args)
      end

      define_method(:headers) do
        endpoints[method_name][:headers]
      end
    end

    HTTP_METHODS = %i[get post patch put delete].freeze

    HTTP_METHODS.each do |http_method|
      define_method http_method do |*args|
        begin
          wrap client.send(http_method, *http_argumets(args))
        rescue HTTP::ConnectionError => e
          failure(body: e.message, status: :not_connected)
        end
      end
    end

    def initialize
      api_settings_exist
      @client = HTTP::Client.new(headers: headers)
    end

    private

    def wrap(response)
      response.status < 300 ? success(response) : failure(response)
    end

    def success(response)
      body = response.body.to_s
      result = !body.empty? ? JSON.parse(body, symbolize_names: true) : nil
      Dry::Monads.Right(result)
    end

    def failure(response)
      result = ApiStruct::Errors::Client.new(response)
      Dry::Monads.Left(result)
    end

    def first_arg(args)
      args.first.to_s
    end

    def http_argumets(args)
      args[0] = root + first_arg(args) if args[0].instance_of?(String)
      args.unshift(root) if args[0].instance_of?(Hash)
      args
    end

    def api_settings_exist
      return if respond_to?(:root)
      raise RuntimeError, "\nSet api configuration for #{self.class}."
    end
  end
end
