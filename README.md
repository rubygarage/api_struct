# ApiStruct

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'api_struct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install api_struct

## Usage

```ruby
API_ROOT = 'http://localhost:3000/api/v1'

# ApiStruct::Client.configure do
#   setting :first_api, API_ROOT
#   setting :second_api
# end

class NetworkClient < ApiStruct::Client
  # first_api '/networks'
  url API_ROOT + '/networks'

  def show(network)
    get(url + "/#{network}")
  end

  def index
    get(url)
  end
end

class User < ApiStruct::Entity
  attr_entity :name, :id
end

class Network < ApiStruct::Entity
  client_service NetworkClient

  attr_entity :name, :id

  has_entity :super_admin, as: User
end

network = Network.show('T7WU9CG65')
networks = Network.index
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/api_struct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
