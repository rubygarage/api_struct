module ApiStruct
  class Client
    attr_reader :client

    HTTP_METHODS = %i[get post patch put delete].freeze

    def self.url(value)
      define_method :url do
        value
      end
    end

    def self.headers(value)
      define_method :headers do
        value
      end
    end

    headers(
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    )

    def initialize
      @client = HTTP::Client.new(headers: headers)
    end

    HTTP_METHODS.each do |http_method|
      define_method http_method do |*args|
        begin
          wrap client.send(http_method, *args)
        rescue HTTP::ConnectionError => error
          failure(body: error.message, status: :not_connected)
        end
      end
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
  end
end
