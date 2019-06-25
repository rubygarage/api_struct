# <img src='https://github.com/rubygarage/api_struct/blob/master/api_struct.svg' height='60' alt='ApiStruct' />

**ApiStruct** consists of two main interfaces: `ApiStruct::Client` and `ApiStruct::Entity`. The `ApiStruct::Client` class is aimed at using the same interface for describing requests to different APIs. The `ApiStruct::Entity` enables you to use *ApiStruct* clients in ORM-like style.

[![Gem Version](https://badge.fury.io/rb/api_struct.svg)](https://badge.fury.io/rb/api_struct)
![Maintainability](https://api.codeclimate.com/v1/badges/dc07c83ccbcaaebc6c44/maintainability)
[![CircleCI](https://circleci.com/gh/rubygarage/api_struct/tree/master.svg?style=svg)](https://circleci.com/gh/rubygarage/api_struct/tree/master)

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
      params: { token: 'Default token' }
    }
  }
end
```

# Client
Endpoint wrapper

```ruby
class PostsClient < ApiStruct::Client
  first_api :posts

  def show(id)
    get(id)
  end

  def index
    get
  end

  def user_posts(user_id, post_id = nil)
    get(post_id, prefix: [:users, user_id])
    # alias:
    # get(post_id, prefix: '/users/:id', id: user_id)
  end

  def custom_path(user_id)
    get(path: 'users_posts/:user_id', user_id: user_id)
  end
end
```

Usage:
```ruby
PostsClient.new.get(1) # -> /posts/1
```
Returns `Result` [monad](https://dry-rb.org/gems/dry-monads/1.0/result/)
```ruby
# => Success({:id=>1, :title=>"Post"})
```

Other methods from sample:
```ruby
post_client = PostsClient.new

post_client.index            # -> /posts
post_client.user_posts(1)    # -> /users/1/posts
post_client.user_posts(1, 2) # -> /users/1/posts/2
post_client.custom_path(1)   # -> /users_posts/1/
```


# Entity
Response serializer

```ruby
class User < ApiStruct::Entity
  client_service UsersClient

  client_service AuthorsClient, prefix: true, only: :index
  # alias:
  # client_service AuthorsClient, prefix: :prefix, except: :index

  attr_entity :name, :id
end
```

```ruby
class UsersClient < ApiStruct::Client
  first_api :users

  def show(id)
    get(id)
  end
end
```

```ruby
class AuthorsClient < ApiStruct::Client
  first_api :authors

  def index
    get
  end
end
```

Usage:
```ruby
user = User.show(1)
# => {"id"=>1, "name"=>"John"}
```

Call methods from prefixed clients:
```ruby
users = User.authors_client_index
# or
# users = User.prefix_index
```

Response serializers with related entities:
```ruby
class Network < ApiStruct::Entity
  client_service NetworkClient

  attr_entity :name, :id
  attr_entity :state, &:to_sym

  has_entity :super_admin, as: User
end
```

```ruby
class NetworkClient < ApiStruct::Client
  first_api :networks

  def show(id)
    get(id)
  end
end
```

Usage:
```ruby
network = Network.show(1)
# => {"id"=>1, "name"=>"Main network", "state"=>"active", "super_admin"=>{"id"=>1, "name"=>"John"}}

network.state
# => :active
```

## Dynamic headers:

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
  first_api :posts

  def update(id, post_data)
    put(id, json: post_data, headers: AuthHeaderValue.call)
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubygarage/api_struct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
***
<a href="https://rubygarage.org/"><img src="https://rubygarage.s3.amazonaws.com/assets/assets/rg_color_logo_horizontal-919afc51a81d2e40cb6a0b43ee832e3fcd49669d06785156d2d16fd0d799f89e.png" alt="RubyGarage Logo" width="415" height="128"></a>

RubyGarage is a leading software development and consulting company in Eastern Europe. Our main expertise includes Ruby and Ruby on Rails, but we successfully employ other technologies to deliver the best results to our clients. [Check out our portfolio](https://rubygarage.org/portfolio) for even more exciting works!
