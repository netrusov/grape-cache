# frozen_string_literal: true

RSpec.describe Grape::Endpoint do
  let(:app) { Class.new(Grape::API) }
  let(:backend) { ActiveSupport::Cache::MemoryStore.new }

  before do
    Grape::Cache.config.backend = backend
  end

  after { backend.cleanup }

  context 'without cache' do
    before do
      app.get '/' do
        rand
      end
    end

    it "always returns different results and doesn't touch the cache" do
      expect(backend).not_to receive(:read)
      expect(backend).not_to receive(:write)

      r1 = get('/')
      r2 = get('/')

      expect(r1.body).not_to eq(r2.body)
    end
  end

  context 'with cache' do
    before do
      app.cache do
        expires_in 1.minute
      end
      app.get '/' do
        rand
      end
    end

    it 'always returns the result of the first run' do
      expect(backend).to receive(:read).twice.and_call_original
      expect(backend).to receive(:write).once.and_call_original

      r1 = get('/')
      r2 = get('/')

      expect(r1.body).to eq(r2.body)
    end
  end

  context 'with different response serializers' do
    let(:default_format) { :txt }
    let(:helper) do
      Module.new do
        module_function

        def data
          {
            k1: :v1,
            k2: :v2
          }
        end
      end
    end

    before do
      app.default_format default_format
      app.helpers helper
      app.cache do
        expires_in 1.minute
      end
      app.get '/' do
        data
      end
    end

    shared_examples 'serialized response' do
      it 'must cache serialized response' do
        expect(backend).to receive(:write)
                             .once
                             .with(kind_of(String), serialized_response, kind_of(Hash))
                             .and_call_original

        2.times { get '/' }

        expect(last_response.body).to eq(serialized_response)
      end
    end

    context 'JSON' do
      let(:default_format) { :json }
      let(:serialized_response) { helper.data.to_json }

      it_behaves_like 'serialized response'
    end

    context 'XML' do
      let(:default_format) { :xml }
      let(:serialized_response) { helper.data.to_xml }

      it_behaves_like 'serialized response'
    end
  end
end
