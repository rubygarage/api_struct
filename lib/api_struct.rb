require 'http'
require 'dry/monads/result'
require 'dry-configurable'
require 'dry/inflector'
require 'json'
require 'hashie'

require_relative 'api_struct/version'
require_relative 'api_struct/settings'
require_relative 'api_struct/concerns/underscore'
require_relative 'api_struct/extensions/api_client'
require_relative 'api_struct/extensions/dry_monads'
require_relative 'api_struct/errors/client'
require_relative 'api_struct/client'
require_relative 'api_struct/collection'
require_relative 'api_struct/entity'
require_relative 'api_struct/errors/entity'

module ApiStruct
end
