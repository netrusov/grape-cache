# frozen_string_literal: true

require 'active_support/cache'
require 'active_support/concern'
require 'grape'
require 'rack'

require 'grape/cache/configurable'
require 'grape/cache/dsl'
require 'grape/cache/helpers'
require 'grape/cache/version'

require 'grape/cache/extensions/dsl'
require 'grape/cache/extensions/instance'
require 'grape/cache/extensions/middleware/formatter'

module Grape
  # @nodoc
  module Cache
    include Grape::Cache::Configurable

    # @param key [String] cache key
    # @return [Object] response object
    def self.read(key)
      config.backend.read(key)
    end

    # @param key [String] cache key
    # @param value [Object] response object
    # @param options [Object] (see ActiveSupport::Cache#write)
    # @return [Boolean] operation status
    def self.write(key, value, **options)
      return false unless value

      options.delete(:expires_in) if options[:expires_in]&.<=(0)
      config.backend.write(key, value, options)
    rescue StandardError => e
      ActiveSupport::Notifications.instrument('grape_cache.write_error', error: e)
      false
    end
  end
end

Grape::API::Instance.include(Grape::Cache::Extensions::DSL)
Grape::API::Instance.include(Grape::Cache::Extensions::Instance)
Grape::Middleware::Formatter.prepend(Grape::Cache::Extensions::Middleware::Formatter)
