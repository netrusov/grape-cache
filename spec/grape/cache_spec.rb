# frozen_string_literal: true

RSpec.describe Grape::Cache do
  let(:backend) { ActiveSupport::Cache::MemoryStore.new }

  before do
    Grape::Cache.config.backend = backend
  end

  after { backend.cleanup }

  describe '.write' do
    let(:key) { 'key' }
    let(:value) { 'hit' }
    let(:options) { {} }

    subject { described_class.write(key, value, options) }

    after { subject }

    context 'when expires_in is <= 0' do
      let(:options) { { expires_in: 0, race_condition_ttl: 5.seconds } }

      it 'removes it from the options' do
        expect(backend).to receive(:write).with(key, value, { race_condition_ttl: 5 })
      end
    end
  end

  describe '.expand_cache_key' do
    let(:app) { Class.new(Grape::API) }
    let(:key) { %w[foo bar] }
    let(:route) { '/users' }

    subject { described_class.expand_cache_key(last_request.env, key) }

    before do
      app.get route do
        'response'
      end
    end

    it 'generates cache key in the following format: (<http-method>)/(<route>)/-(/<additional-arguments>)*' do
      get route

      is_expected.to eq("GET/#{route}/-/foo/bar")
    end
  end

  describe '.with_cached_response' do
    let(:key) { 'key' }
    let(:backend_key) { 'not-the-right-one' }
    let(:hit_value) { 'hit' }
    let(:miss_value) { 'miss' }
    let(:env) { {} }
    let(:options) { {} }

    subject do
      described_class.with_cached_response(env, key, options) { miss_value }
    end

    before do
      backend.write(backend_key, hit_value)
      subject
    end

    context 'on cache miss' do
      it 'executes block' do
        is_expected.to eq(miss_value)
      end

      it 'sets :hit to false' do
        expect(env['grape-cache'][:hit]).to eq(false)
      end

      it "doesn't set :value" do
        expect(env['grape-cache'][:value]).to be_nil
      end
    end

    context 'on cache hit' do
      let(:backend_key) { key }

      it 'returns cached value' do
        is_expected.to eq(hit_value)
      end

      it 'sets :hit to true' do
        expect(env['grape-cache'][:hit]).to eq(true)
      end

      it 'sets :value to cached value' do
        expect(env['grape-cache'][:value]).to eq(hit_value)
      end
    end
  end
end
