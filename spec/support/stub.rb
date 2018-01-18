module Support
  module Stub
    def stub_api(root)
      ApiStruct::Settings.configure do |config|
        config.endpoints = { stub_api: { root: root } }
      end
    end
  end
end
