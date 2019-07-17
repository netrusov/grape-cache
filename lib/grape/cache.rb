# frozen_string_literal: true

require 'grape'

require 'grape/cache/dsl'
require 'grape/cache/helpers'
require 'grape/cache/version'

module Grape
  module Cache
    # @param config [Grape::Cache::Config] configuration instance created in "cache" block
    # @return [Proc] route block with caching logic
    def self.generate_route_method(config, &block)
      return block unless config

      proc do
        header 'Cache-Control', config[:cache_control]

        cache_key =
          config[:key]
          .then { |key| key.is_a?(Proc) ? instance_eval(&key) : key }
          .then { |key| expand_cache_key(*key) }

        if Rails.cache.exist?(cache_key)
          Grape::Cache.read cache_key
        else
          instance_eval(&block).tap do |response|
            Grape::Cache.store cache_key, (body || response), config[:expires_in]
          end
        end
      end
    end

    # @param key [String] cache key
    # @return [Object] response object
    def self.read(key)
      key
        .then(&Rails.cache.method(:read))
        .then(&Grape::Json.method(:load))
    end

    # @param key [String]
    # @param response [String]
    # @param ttl [Integer]
    # @return [void]
    def self.store(key, response, expires_in)
      options = {}
      options[:expires_in] = expires_in if expires_in > 0

      Rails.cache.write(key, Grape::Json.dump(response), options) if response
    end
  end
end

Grape::API::Instance.class_eval do
  include Grape::Cache::DSL

  helpers Grape::Cache::Helpers
end
