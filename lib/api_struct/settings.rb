module ApiStruct
  class Settings
    extend ::Dry::Configurable

    setting :endpoints, {}
  end
end
