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

Initialize APIs routes:

```ruby
ApiStruct::Settings.configure do |config|
  config.endpoints = {
    first_api: {
      root: 'http://localhost:3000/api/v1',
      headers: {
        'content-type': 'application/json',
        'Authorization': 'Bearer TOKEN'
      }
    },
    second_api: {
      root: 'http://localhost:3001/api/v1',
      # etc...
    }
  }
end
```

Endpoint client:
```ruby
class NetworkClient < ApiStruct::Client
  first_api '/networks'

  def show(id)
    get("/#{id}")
  end

  def index
    get
  end
end
```

Response serializers:
```ruby
class User < ApiStruct::Entity
  attr_entity :name, :id
end

class Network < ApiStruct::Entity
  client_service NetworkClient

  attr_entity :name, :id
  attr_entity :state, &:to_sym

  has_entity :super_admin, as: User
end
```

Usage:
```ruby
network = Network.show('T7WU9CG65')
networks = Network.index
```

## More samples

Nested resources:

```ruby
class PostClient < ApiStruct::Client
  first_api '/users'

  def update(user_id, id, post_data)
    put("/#{user_id}/posts/#{id}", json: post_data)
  end
end
```

Dynamic headers:

```ruby
class Auth
  def self.call
    # Get a token..
  end
end
```

```ruby
class AuthHeaderValue
  def self.call
    { "Authorization": "Bearer #{Auth.call}" }
  end
end
```

```ruby
class PostClient < ApiStruct::Client
  first_api '/users'

  def update(user_id, id, post_data)
    put("/#{user_id}/posts/#{id}", json: post_data, headers: AuthHeaderValue.call)
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubygarage/api_struct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
