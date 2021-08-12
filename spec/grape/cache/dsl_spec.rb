# frozen_string_literal: true

RSpec.describe Grape::Cache::DSL do
  subject { Grape::Cache::DSL.new }

  describe '#key' do
    let(:key) { %w[foo bar baz] }

    before do
      subject.key key
    end

    it 'simply stores any value passed' do
      expect(subject[:key]).to eq(key)
    end
  end

  describe '#expires_in' do
    let(:expires_in) { '60' }

    before do
      subject.expires_in expires_in
    end

    it 'converts any value to integer' do
      expect(subject[:expires_in]).to eq(expires_in.to_i)
    end
  end

  describe '#race_condition_ttl' do
    let(:ttl) { '60' }

    before do
      subject.race_condition_ttl ttl
    end

    it 'converts any value to integer' do
      expect(subject[:race_condition_ttl]).to eq(ttl.to_i)
    end
  end

  describe '#cache_control' do
    let(:default_value) { 'private, no-cache, must-revalidate' }
    let(:max_age) { 1.minute }

    before do
      subject.cache_control options
    end

    context 'max-age' do
      let(:options) { { max_age: max_age } }

      it 'sets cache TTL' do
        expect(subject[:cache_control]).to eq("private, max-age=#{max_age.to_i}")
      end
    end

    context 'public' do
      context 'when max-age is not set' do
        let(:options) { { public: true } }

        it 'stays private' do
          expect(subject[:cache_control]).to eq('private, no-cache, must-revalidate')
        end
      end

      context 'when max-age is set' do
        let(:options) { { public: true, max_age: max_age } }

        it 'becomes public' do
          expect(subject[:cache_control]).to eq("public, max-age=#{max_age.to_i}")
        end
      end
    end

    context 'must-revalidate' do
      context 'when max-age is not set' do
        let(:options) { { must_revalidate: false } }

        it 'stays present' do
          expect(subject[:cache_control]).to eq('private, no-cache, must-revalidate')
        end
      end

      context 'when max-age is set' do
        let(:options) { { must_revalidate: false, max_age: max_age } }

        it 'becomes absent' do
          expect(subject[:cache_control]).to eq("private, max-age=#{max_age.to_i}")
        end

        context 'when must-revalidate is set to true' do
          let(:options) { { must_revalidate: true, max_age: max_age } }

          it 'stays present' do
            expect(subject[:cache_control]).to eq("private, max-age=#{max_age.to_i}, must-revalidate")
          end
        end
      end
    end
  end
end
