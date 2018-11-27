describe ApiStruct::Client do
  extend Support::Stub
  let(:api_root) { 'https://jsonplaceholder.typicode.com' }
  stub_api('https://jsonplaceholder.typicode.com')

  class StubClient < ApiStruct::Client
    stub_api :posts

    def show(id)
      get(id)
    end

    def update(id, params)
      patch(id, json: params)
    end
  end

  context 'build url options' do
    context 'url options' do
      let(:client) { StubClient.new }
      it ' should replace /posts/users/:id to /posts/users if URL option didnt provided' do
        url = client.send(:build_url, 'users/:id', {})
        expect(url).to eq api_root + '/posts/users'
      end

      it ' should replace users/:id/comments to users/comments if URL option didnt provided' do
        url = client.send(:build_url, 'users/:id/comments', {})
        expect(url).to eq api_root + '/posts/users/comments'
      end

      it 'should replace /users/:id in prefix to /users/1' do
        url = client.send(:build_url, [], prefix: 'users/:id', id: 1)
        expect(url).to eq api_root + '/users/1/posts'
      end

      it 'should replace /users/:user_id/posts/:id in prefix to /users/1/posts/12' do
        url = client.send(:build_url, ':id', prefix: 'users/:user_id', user_id: 1, id: 12)
        expect(url).to eq api_root + '/users/1/posts/12'
      end

      it 'should replace /users/:id to /users/1' do
        url = client.send(:build_url, 'users/:id', id: 1)
        expect(url).to eq api_root + '/posts/users/1'
      end

      it 'user_posts without post_id' do
        user_id = 1
        post_id = nil
        url = client.send(:build_url, post_id, prefix: [:users, user_id])
        expect(url).to eq api_root + '/users/1/posts'
      end

      it 'user_posts with post_id' do
        user_id = 1
        post_id = 2
        url = client.send(:build_url, post_id, prefix: [:users, user_id])
        expect(url).to eq api_root + '/users/1/posts/2'
      end
    end
    it 'should build url with prefix' do
      VCR.use_cassette('users/1/posts') do
        response = StubClient.new.get(prefix: 'users/:id', id: 1)
        expect(response).to be_success
        expect(response.value!).to be_kind_of Array
        expect(response.value!).not_to be_empty
      end
    end

    it 'should build url with custom path' do
      VCR.use_cassette('todos') do
        response = StubClient.new.get(path: 'todos/1')
        expect(response).to be_success
        expect(response.value![:id]).to eq(1)
        expect(response.value![:title]).not_to be_empty
        expect(response.value!.keys).to include(:completed)
      end
    end

    it 'should build url with prefix as array' do
      VCR.use_cassette('todos') do
        response = StubClient.new.get(path: [:todos, 1])
        expect(response).to be_success
        expect(response.value![:id]).to eq(1)
        expect(response.value![:title]).not_to be_empty
        expect(response.value!.keys).to include(:completed)
      end
    end
  end

  context 'GET' do
    it 'when successful response' do
      VCR.use_cassette('posts/show_success') do
        response = StubClient.new.show(1)
        expect(response).to be_success
        expect(response.value![:id]).to eq(1)
        expect(response.value![:title]).not_to be_empty
      end
    end

    it 'when failed response' do
      VCR.use_cassette('posts/show_failure') do
        response = StubClient.new.show(101)
        expect(response).to be_failure
        expect(response.failure.status).to eq(404)
      end
    end

    it 'when failed response with html response' do
      VCR.use_cassette('posts/show_failure_html') do
        response = StubClient.new.show(101)
        body     = response.failure.body
        expect(response).to be_failure
        expect(response.failure.status).to eq(404)
        expect(body).to be_kind_of(String)
        expect(body).to match(/<body>.+<\/body>/)
      end
    end
  end

  context 'PATCH' do
    it 'when successful response' do
      VCR.use_cassette('posts/update_success') do
        response = StubClient.new.update(1, title: FFaker::Name.name)
        expect(response).to be_success
        expect(response.value![:id]).to eq(1)
      end
    end
  end
end
