module ApiStruct
  module Errors
    class Entity < ApiStruct::Entity
      attr_entity :body, :status, :error
    end
  end
end
