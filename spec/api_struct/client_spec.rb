describe ApiStruct::Client do
  ApiStruct::Settings.configure do |config|
    config.endpoints = {
      stub_api: {
        root: 'https://jsonplaceholder.typicode.com'
      }
    }
  end

  class StubClient < ApiStruct::Client
    stub_api '/posts'

    def show(id)
      get("/#{id}")
    end
    
    def update(id, params)
      patch("/#{id}", json: params)
    end
  end

  context 'Get' do
    it 'Success', type: :webmock do
      VCR.use_cassette('posts/get_success') do
        response = StubClient.new.show(1)
        expect(response).to be_success
        expect(response.value[:id]).to eq(1)
        expect(response.value[:title]).not_to be_empty
      end
    end

    it 'Failure', type: :webmock do
      VCR.use_cassette('posts/get_failure') do
        response = StubClient.new.show(101)
        expect(response).to be_failure
        expect(response.value.status).to eq(404)
      end
    end
  end

  context 'Patch' do
    it 'Success', type: :webmock do
      VCR.use_cassette('posts/update_success') do
        response = StubClient.new.update(1, title: FFaker::Name.name)
        expect(response).to be_success
        expect(response.value[:id]).to eq(1)
      end
    end
  end
end
