# frozen_string_literal: true

module Grape
  module Cache
    # @nodoc
    module Helpers
      module_function

      # @param env [Object] request env
      # @param key [#to_s, Array<#to_s>] any object or array of objects that respond to `#to_s`
      # @return [String] cache key
      def expand_cache_key(env, key)
        key = [
          env[Rack::REQUEST_METHOD],
          env[Rack::PATH_INFO],
          '-'
        ] + Array(key).compact

        ActiveSupport::Cache.expand_cache_key(key)
      end
    end
  end
end
