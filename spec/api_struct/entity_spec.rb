describe ApiStruct::Entity do
  extend Support::Stub

  stub_api('https://jsonplaceholder.typicode.com')

  class StubClient < ApiStruct::Client
    stub_api 'posts'

    def show(id)
      get(id)
    end

    def index(params = {})
      get(json: params)
    end
  end

  class AnotherStubClient  < ApiStruct::Client
    stub_api 'posts'

    def pull(id)
      get(id)
    end
  end

  class StubNestedEntity < ApiStruct::Entity
    attr_entity :name
  end

  class StubEntity < ApiStruct::Entity
    client_service StubClient
    client_service StubClient, prefix: true
    client_service StubClient, prefix: :custom
    client_service StubClient, prefix: :only, only: :index
    client_service StubClient, prefix: :except, except: :show
    client_service AnotherStubClient

    attr_entity :id, :title, :camel_case

    has_entity :nested_entity, as: StubNestedEntity
    has_entities :another_nested_entities, as: StubNestedEntity
  end

  let(:response) { { title: FFaker::Name.name, 'id' => rand(1..100), another_attributes: FFaker::Name.name } }
  let(:nested_response) { { name: FFaker::Name.name } }

  it '.new' do
    entity = StubEntity.new(response)

    expect(entity).to be_success
    expect(entity.id).to eq(response['id'])
    expect(entity.title).to eq(response[:title])
    expect { entity.another_attributes }.to raise_error(NoMethodError)
  end

  it '.collection' do
    entities = StubEntity.collection([response, response])

    expect(entities.count).to eq(2)
    expect(entities.success?).to eq(true)
    expect(entities.failure?).to eq(false)
    expect(entities.class).to eq(ApiStruct::Collection)
    expect(entities.first.title).to eq(response[:title])
  end

  context 'Nested entity' do
    it 'when response is valid' do
      response[:nested_entity] = nested_response
      entity = StubEntity.new(response)
      nested_entity = entity.nested_entity

      expect(nested_entity.class).to eq(StubNestedEntity)
      expect(nested_entity.name).to eq(nested_response[:name])
    end

    it 'when response is invalid' do
      response[:nested_entity] = [nested_response]
      entity = StubEntity.new(response)

      expect { entity.nested_entity }.to raise_error(ApiStruct::EntityError)
    end
  end

  context 'Nested entities' do
    it 'when response is valid' do
      response[:another_nested_entities] = [nested_response]
      entity = StubEntity.new(response)
      nested_entity = entity.another_nested_entities.first

      expect(nested_entity.class).to eq(StubNestedEntity)
      expect(nested_entity.name).to eq(nested_response[:name])
    end

    it 'when response is invalid' do
      response[:another_nested_entities] = nested_response
      entity = StubEntity.new(response)

      expect { entity.another_nested_entities }.to raise_error(ApiStruct::EntityError)
    end
  end

  context 'From monad' do
    it 'convert to entity', type: :webmock do
      VCR.use_cassette('posts/show_success') do
        entity = StubEntity.from_monad(StubClient.new.show(1))

        expect(entity).to be_success
        expect(entity.id).to eq(1)
        expect(entity.title).not_to be_empty
      end
    end

    it 'convert to collection of entities', type: :webmock do
      VCR.use_cassette('posts/index_success') do
        entities = StubEntity.from_monad(StubClient.new.index)

        expect(entities.class).to eq(ApiStruct::Collection)
        expect(entities.first.id).to eq(1)
      end
    end
  end

  context 'From client service' do
    it 'convert to entity', type: :webmock do
      VCR.use_cassette('posts/show_success') do
        entity = StubEntity.show(1)

        expect(entity).to be_success
        expect(entity.id).to eq(1)
        expect(entity.title).not_to be_empty
        expect(entity.camel_case).not_to be_empty
      end
    end

    it 'convert to collection of entities', type: :webmock do
      VCR.use_cassette('posts/index_success') do
        entities = StubEntity.index

        expect(entities.class).to eq(ApiStruct::Collection)
        expect(entities.first.id).to eq(1)
      end
    end
  end

  describe '.client_service' do
    context 'prefix' do
      context 'empty' do
        it 'should register client as its class name' do
          expect(StubEntity.clients[:stub_client]).to eq StubClient
          expect(StubEntity.clients[:another_stub_client]).to eq AnotherStubClient
        end

        it 'should define client methods without prefix' do
          expect(StubEntity).to be_respond_to(:show)
          expect(StubEntity).to be_respond_to(:index)
        end
      end

      context 'eq true' do
        it 'should register client as stubclient' do
          expect(StubEntity.clients[:stub_client]).to eq StubClient
        end

        it 'should define client methods' do
          expect(StubEntity).to be_respond_to(:stub_client_show)
          expect(StubEntity).to be_respond_to(:stub_client_index)
        end
      end

      context 'eq string' do
        it 'should register client as custom' do
          expect(StubEntity.clients[:custom]).to eq StubClient
        end

        it 'should define client methods' do
          expect(StubEntity).to be_respond_to(:custom_show)
          expect(StubEntity).to be_respond_to(:custom_index)
        end
      end
    end

    context 'only' do
      it 'should define methods from options[:only]' do
        expect(StubEntity).to be_respond_to(:only_index)
        expect(StubEntity).not_to be_respond_to(:only_show)
      end
    end

    context 'except' do
      it 'should define all methods except options[:except]' do
        expect(StubEntity).to be_respond_to(:except_index)
        expect(StubEntity).not_to be_respond_to(:except_show)
      end
    end

    context 'two clients' do
      it 'should define methods from multiple clients' do
        expect(StubEntity).to be_respond_to(:index)
        expect(StubEntity).to be_respond_to(:show)
        expect(StubEntity).to be_respond_to(:pull)
      end
    end
  end
end
