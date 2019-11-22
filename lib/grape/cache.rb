# frozen_string_literal: true

require 'rack'
require 'grape'

require 'grape/cache/configurable'
require 'grape/cache/extensions/dsl'
require 'grape/cache/extensions/endpoint'
require 'grape/cache/helpers'
require 'grape/cache/version'

module Grape
  module Cache
    include Grape::Cache::Configurable

    # @param key [String] cache key
    # @return [Object] response object
    def self.read(key)
      config
        .backend
        .read(key)
        .then { |result| Grape::Json.load(result) if result }
    end

    # @param key [String] cache key
    # @param response [Object] response object
    # @param options [Object] (see ActiveSupport::Cache#write)
    # @return [Boolean] operation status
    def self.store(key, response, options)
      return false unless response

      Grape::Json
        .dump(response)
        .then { |value| config.backend.write(key, value, options) }
    end
  end
end

Grape::API::Instance.class_exec do
  include Grape::Cache::Extensions::DSL
  include Grape::Cache::Extensions::Endpoint

  helpers Grape::Cache::Helpers
end
