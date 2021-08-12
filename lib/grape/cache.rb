# frozen_string_literal: true

require 'grape'
require 'rack'

require 'active_support/cache'
require 'active_support/concern'
require 'active_support/notifications'

require 'grape/cache/configurable'
require 'grape/cache/dsl'
require 'grape/cache/version'

require 'grape/cache/extensions/dsl'
require 'grape/cache/extensions/instance'
require 'grape/cache/extensions/middleware/formatter'

module Grape
  # @nodoc
  module Cache
    include Grape::Cache::Configurable

    # @param key [String] cache key
    # @return [String] serialized response object
    def self.read(key)
      config.backend.read(key)
    end

    # @param key [String] cache key
    # @param value [Object] response object
    # @param options [Object] (see ActiveSupport::Cache#write)
    # @return [Boolean] operation status
    def self.write(key, value, options)
      return false unless value

      options = options.except(:expires_in) if options[:expires_in]&.<=(0)

      config.backend.write(key, value, options)
    rescue StandardError => e
      ActiveSupport::Notifications.instrument('grape_cache.write_error', error: e)
      false
    end

    # @param env [Object] request env
    # @param key [#to_s, Array<#to_s>] any object or array of objects that respond to `#to_s`
    # @return [String] cache key
    def self.expand_cache_key(env, key)
      key = [
        env[Rack::REQUEST_METHOD],
        env[Rack::PATH_INFO],
        '-'
      ] + Array(key).compact

      ActiveSupport::Cache.expand_cache_key(key)
    end

    # @param env [Object] request env
    # @param key [String] cache key
    # @param context [Grape::Cache::DSL] context object
    # @yield block which will be called on cache miss
    # @return [String, Object] returns cached response or result of executed block
    def self.with_cached_response(env, key, context)
      env['grape-cache'] = { key: key }

      if (value = Grape::Cache.read(key))
        env['grape-cache'][:hit] = true
        env['grape-cache'][:value] = value
      else
        env['grape-cache'][:hit] = false
        env['grape-cache'][:options] = context.slice(:expires_in, :race_condition_ttl).compact

        yield
      end
    end
  end
end

Grape::API::Instance.include(Grape::Cache::Extensions::DSL)
Grape::API::Instance.include(Grape::Cache::Extensions::Instance)
Grape::Middleware::Formatter.prepend(Grape::Cache::Extensions::Middleware::Formatter)
