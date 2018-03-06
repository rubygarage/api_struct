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
class PostsClient < ApiStruct::Client
  first_api :posts

  def show(id)
    get(id)
  end

  def index
    get
  end
  
  def user_posts(user_id, post_id = nil)
    get(post_id, prefix: [:users, user_id]) # or get(post_id, prefix: '/users/:id', id: user_id)
  end
  
  def custom_path(user_id)
    get(path: 'users_posts/:user_id', user_id: user_id)
  end
end

# PostsClient.new.get(1)           -> /posts/1
# PostsClient.new.index            -> /posts 
# PostsClient.new.user_posts(1)    -> /users/1/posts
# PostsClient.new.user_posts(1, 2) -> /users/1/posts/2
# PostsClient.new.custom_path(1)   -> /users_posts/1/
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
class UserPostsClient < ApiStruct::Client
  first_api '/users/:user_id/posts'

  def index(user_id)
    get(user_id: user_id)
  end
  
  def show(user_id, post_id)
     get(post_id, user_id: user_id)
  end
end

# UserPostsClient.new.index(1)   -> /users/1/posts
# UserPostsClient.new.show(1, 2) -> /users/1/posts/2
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
